import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  final parser =
      ArgParser()
        ..addFlag('deploy', defaultsTo: true, help: 'Deploy the service')
        ..addFlag(
          'test',
          defaultsTo: true,
          help: 'Run the tests (requires service to be deployed)',
        )
        ..addOption('project', help: 'Google Cloud Project ID')
        ..addOption('service-name', help: 'Cloud Run Service Name')
        ..addOption(
          'region',
          help: 'Cloud Run Region',
          defaultsTo: 'us-central1',
        )
        ..addFlag(
          'help',
          abbr: 'h',
          negatable: false,
          help: 'Show this help message',
        );

  try {
    final results = parser.parse(args);

    if (results['help'] as bool) {
      print('Usage: dart tool/run_e2e.dart [options]');
      print(parser.usage);
      return;
    }

    final config = _E2EConfig.fromArgs(results);
    await _run(config);
  } on FormatException catch (e) {
    print('Error: ${e.message}');
    print('');
    print('Usage: dart tool/run_e2e.dart [options]');
    print(parser.usage);
    exitCode = 1;
  } catch (e) {
    print('Error: $e');
    exitCode = 1;
  }
}

Future<void> _run(_E2EConfig config) async {
  if (!File('pubspec.yaml').existsSync()) {
    throw StateError(
      'pubspec.yaml not found. Run this script from the package root.',
    );
  }

  // 1. Deploy
  if (config.deploy) {
    final result = await _deploySource(config);
    final url = result.$1;
    final resolvedProject = result.$2;
    print('Service deployed successfully: $url (Project: $resolvedProject)');

    if (config.test) {
      await _runTests(url, resolvedProject);
    }
  } else if (config.test) {
    // 2. Just test (no deploy)
    print(
      'Resolving URL for ${config.serviceName} in ${config.region} '
      '(Project: ${config.project})...',
    );
    final url = await _getServiceUrl(
      config.project,
      config.serviceName,
      config.region,
    );
    print('Resolved Service URL: $url');
    await _runTests(url, config.project);
  }
}

Future<void> _runTests(String url, String project) async {
  print('Running tests...');
  final testResult = await Process.start(
    'dart',
    ['test'],
    mode: ProcessStartMode.inheritStdio,
    environment: {'E2E_URL': url, 'GOOGLE_CLOUD_PROJECT': project},
  );

  final exitCode = await testResult.exitCode;
  if (exitCode != 0) {
    print('Tests failed.');
    exit(exitCode);
  } else {
    print('Tests passed!');
  }
}

Future<String> _getServiceUrl(
  String project,
  String serviceName,
  String region,
) async {
  final result = await Process.run('gcloud', [
    'run',
    'services',
    'describe',
    serviceName,
    '--project=$project',
    '--region=$region',
    '--format=json',
  ]);

  if (result.exitCode != 0) {
    throw StateError('Failed to get service URL: ${result.stderr}');
  }

  final output = jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
  final status = output['status'] as Map<String, dynamic>;

  // Try to find the URL for a tag starting with 'e2e-'
  final traffic = status['traffic'] as List?;
  final e2eUrl =
      traffic?.cast<Map<String, dynamic>>().firstWhere(
            (t) => (t['tag'] as String?)?.startsWith('e2e-') ?? false,
            orElse: () => {},
          )['url']
          as String?;

  return e2eUrl ??
      status['url'] as String? ??
      (status['address'] as Map<String, dynamic>?)?['url'] as String;
}

Future<(String, String)> _deploySource(_E2EConfig config) async {
  final project = config.project;
  final serviceName = config.serviceName;
  final region = config.region;

  // 2. Build the project
  print('Building project...');
  const buildDir = 'build';
  const binaryLocation = 'bin/server';
  final binaryPath = p.join(buildDir, binaryLocation);

  Directory(p.dirname(binaryPath)).createSync(recursive: true);

  final buildResult = await Process.run('dart', [
    'compile',
    'exe',
    'bin/server.dart',
    '-o',
    binaryPath,
    '--target-arch',
    'x64',
    '--target-os',
    'linux',
  ]);

  if (buildResult.exitCode != 0) {
    stderr
      ..write(buildResult.stderr)
      ..write(buildResult.stdout);
    throw StateError('Failed to build project.');
  }

  // 3. Deploy to Cloud Run
  print('Deploying to Cloud Run ($serviceName in $region)...');
  final randomTag = 'e2e-${_generateRandomSuffix()}';
  final deployArgs = [
    'beta',
    'run',
    'deploy',
    serviceName,
    '--project=$project',
    '--region=$region',
    '--allow-unauthenticated',
    '--no-build',
    '--base-image=osonly24',
    '--source=$buildDir',
    '--command=$binaryLocation',
    '--tag=$randomTag',
    '--format=json',
  ];

  print('Running: gcloud ${deployArgs.join(' ')}');
  final deployResult = await Process.run('gcloud', deployArgs);

  if (deployResult.exitCode != 0) {
    stderr
      ..write(deployResult.stderr)
      ..write(deployResult.stdout);
    throw StateError('Failed to deploy project.');
  }

  try {
    final output =
        jsonDecode(deployResult.stdout.toString()) as Map<String, dynamic>;
    final status = output['status'] as Map<String, dynamic>;

    // Try to find the URL for the random tag we just created
    final traffic = status['traffic'] as List?;
    final e2eUrl =
        traffic?.cast<Map<String, dynamic>>().firstWhere(
              (t) => t['tag'] == randomTag,
              orElse: () => {},
            )['url']
            as String?;

    final url =
        e2eUrl ??
        status['url'] as String? ??
        (status['address'] as Map<String, dynamic>?)?['url'] as String;
    return (url, project);
  } catch (e) {
    stderr.write('Failed to parse deployment output: ${deployResult.stdout}');
    throw StateError('Failed to parse deployment URL.');
  }
}

class _E2EConfig {
  final bool deploy;
  final bool test;
  final String project;
  final String serviceName;
  final String region;

  _E2EConfig._({
    required this.deploy,
    required this.test,
    required this.project,
    required this.serviceName,
    required this.region,
  }) {
    if (!deploy && !test) {
      throw const FormatException(
        'Cannot run with both --no-deploy and --no-test',
      );
    }
  }

  factory _E2EConfig.fromArgs(ArgResults results) {
    final env = Platform.environment;
    final credentialsFile = File(p.join('.dart_tool', 'credentials.yaml'));
    var fileConfig = <String, String?>{};

    if (credentialsFile.existsSync()) {
      try {
        final yaml = loadYaml(credentialsFile.readAsStringSync());
        if (yaml is Map) {
          fileConfig = yaml.cast<String, String?>();
        }
      } catch (e) {
        print('Warning: Failed to parse .dart_tool/credentials.yaml: $e');
      }
    }

    String? lookup(String key, {String? argKey}) {
      if (argKey != null && results.wasParsed(argKey)) {
        return results[argKey] as String?;
      }
      return fileConfig[key] ?? env[key];
    }

    // Priority: Argument -> File -> Environment -> Default

    var project = lookup('GOOGLE_CLOUD_PROJECT', argKey: 'project');
    project ??= lookup('GCP_PROJECT');

    var serviceName = lookup('SERVICE_NAME', argKey: 'service-name');
    serviceName ??= 'google-cloud-e2e';

    var region = lookup('GOOGLE_CLOUD_REGION', argKey: 'region');
    region ??= lookup('GCP_REGION');
    region ??= 'us-central1';

    return _E2EConfig._(
      deploy: results['deploy'] as bool,
      test: results['test'] as bool,
      project:
          project ??
          (throw const FormatException(
            'Project ID is required. Set it via .dart_tool/credentials.yaml, '
            'GOOGLE_CLOUD_PROJECT environment variable, or pass it as an '
            'argument.',
          )),
      serviceName: serviceName,
      region: region,
    );
  }
}

String _generateRandomSuffix() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rnd = Random();
  return String.fromCharCodes(
    Iterable.generate(8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
  );
}
