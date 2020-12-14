// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:math';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
// ignore: implementation_imports
import 'package:stagehand/src/common.dart';
import 'package:stagehand/stagehand.dart';

import '../version.dart';

const String appName = 'gfn';

final _appPubInfo = Uri.https('pub.dev', '/packages/$appName.json');

class CliApp {
  final List<Generator> generators;
  final CliLogger logger;

  GeneratorTarget target;
  io.Directory _cwd;

  CliApp(this.generators, this.logger, [this.target]) {
    assert(generators != null);
    assert(logger != null);
    generators.sort();
  }

  io.Directory get cwd => _cwd ?? io.Directory.current;

  /// An override for the directory to generate into; public for testing.
  set cwd(io.Directory value) {
    _cwd = value;
  }

  Future process(List<String> args) async {
    var argParser = _createArgParser();

    ArgResults options;

    try {
      options = argParser.parse(args);
    } catch (e, st) {
      // FormatException: Could not find an option named "foo".
      if (e is FormatException) {
        _out('Error: ${e.message}');
        return Future.error(ArgError(e.message));
      } else {
        return Future.error(e, st);
      }
    }

    if (options['version']) {
      _out('$appName version: $packageVersion');
      return http.get(_appPubInfo).then((response) {
        List versions = jsonDecode(response.body)['versions'];
        if (packageVersion != versions.last) {
          _out('Version ${versions.last} is available! Run `pub global activate'
              ' $appName` to get the latest.');
        }
      }).catchError((e) => null);
    }

    // The `--machine` option emits the list of available generators to stdout
    // as JSON. This is useful for tools that don't want to have to parse the
    // output of `--help`. It's an undocumented command line flag, and may go
    // away or change.
    if (options['machine']) {
      logger.stdout(_createMachineInfo(generators));
    }

    if (options.rest.isEmpty) {
      logger.stderr('No generator specified.\n');
      _usage(argParser);
      return Future.error(ArgError('no generator specified'));
    }

    if (options.rest.length >= 2) {
      logger.stderr('Error: too many arguments given.\n');
      _usage(argParser);
      return Future.error(ArgError('invalid generator'));
    }

    var generatorName = options.rest.first;
    var generator = _getGenerator(generatorName);

    if (generator == null) {
      logger.stderr("'$generatorName' is not a valid generator.\n");
      _usage(argParser);
      return Future.error(ArgError('invalid generator'));
    }

    var dir = cwd;

    if (!options['override'] && !await _isDirEmpty(dir)) {
      logger.stderr(
          'The current directory is not empty. Please create a new project directory, or '
          'use --override to force generation into the current directory.');
      return Future.error(ArgError('project directory not empty'));
    }

    // Normalize the project name.
    var projectName = path.basename(dir.path);
    projectName = normalizeProjectName(projectName);

    target ??= _DirectoryGeneratorTarget(logger, dir);

    _out('Creating $generatorName application `$projectName`:');

    String author = options['author'];

    if (!options.wasParsed('author')) {
      try {
        var result = io.Process.runSync('git', ['config', 'user.name']);
        if (result.exitCode == 0) author = result.stdout.trim();
      } catch (exception) {
        // NOOP
      }
    }

    var email = 'email@example.com';

    try {
      var result = io.Process.runSync('git', ['config', 'user.email']);
      if (result.exitCode == 0) email = result.stdout.trim();
    } catch (exception) {
      // NOOP
    }

    var vars = {'author': author, 'email': email};

    var f = generator.generate(projectName, target, additionalVars: vars);
    return f.then((_) {
      _out('${generator.numFiles()} files written.');

      var message = generator.getInstallInstructions();
      if (message != null && message.isNotEmpty) {
        message = message.trim();
        message = message.split('\n').map((line) => '--> $line').join('\n');
        _out('\n$message');
      }
    });
  }

  ArgParser _createArgParser() {
    var argParser = ArgParser();

    argParser.addFlag('analytics',
        negatable: true,
        help: 'Opt out of anonymous usage and crash reporting.');
    argParser.addFlag('help', abbr: 'h', negatable: false, help: 'Help!');
    argParser.addFlag('version',
        negatable: false, help: 'Display the version for $appName.');
    argParser.addOption('author',
        defaultsTo: '<your name>',
        help: 'The author name to use for file headers.');

    // Really, really generate into the current directory.
    argParser.addFlag('override', negatable: false, hide: true);

    // Output the list of available projects as JSON to stdout.
    argParser.addFlag('machine', negatable: false, hide: true);

    // Mock out analytics - for use on our testing bots.
    argParser.addFlag('mock-analytics', negatable: false, hide: true);

    return argParser;
  }

  String _createMachineInfo(List<Generator> generators) {
    var itor = generators.map((Generator generator) {
      var m = {
        'name': generator.id,
        'label': generator.label,
        'description': generator.description,
        'categories': generator.categories
      };

      if (generator.entrypoint != null) {
        m['entrypoint'] = generator.entrypoint.path;
      }

      return m;
    });
    return json.encode(itor.toList());
  }

  void _usage(ArgParser argParser) {
    _out(
        'Stagehand will generate the given application type into the current directory.');
    _out('');
    _out('usage: $appName <generator-name>');
    _out(argParser.usage);
    _out('');
    _out('Available generators:');
    var len = generators.fold(0, (int length, g) => max(length, g.id.length));
    generators
        .map((g) => '  ${g.id.padRight(len)} - ${g.description}')
        .forEach(logger.stdout);
  }

  Generator _getGenerator(String id) {
    return generators.firstWhere((g) => g.id == id, orElse: () => null);
  }

  void _out(String str) => logger.stdout(str);

  /// Returns true if the given directory does not contain non-symlinked,
  /// non-hidden subdirectories.
  static Future<bool> _isDirEmpty(io.Directory dir) async {
    var isHiddenDir = (dir) => path.basename(dir.path).startsWith('.');

    return dir
        .list(followLinks: false)
        .where((entity) => entity is io.Directory)
        .where((entity) => !isHiddenDir(entity))
        .isEmpty;
  }
}

class ArgError implements Exception {
  final String message;
  ArgError(this.message);

  @override
  String toString() => message;
}

class CliLogger {
  void stdout(String message) => print(message);
  void stderr(String message) => print(message);
}

class _DirectoryGeneratorTarget extends GeneratorTarget {
  final CliLogger logger;
  final io.Directory dir;

  _DirectoryGeneratorTarget(this.logger, this.dir) {
    dir.createSync();
  }

  @override
  Future createFile(String filePath, List<int> contents) {
    var file = io.File(path.join(dir.path, filePath));

    logger.stdout('  ${file.path}');

    return file
        .create(recursive: true)
        .then((_) => file.writeAsBytes(contents));
  }
}
