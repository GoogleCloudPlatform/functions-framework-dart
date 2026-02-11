// Copyright 2022 Google LLC
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

import 'dart:io';

import 'package:google_cloud/google_cloud.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  group('currentProjectId', () {
    const projectIdPrint = 'test/src/project_id_print.dart';

    tearDown(clearProjectIdCache);

    test(
      'not environment',
      onPlatform: {'windows': const Skip('Cannot validate tests on windows.')},
      () async {
        final proc = await _run(projectIdPrint);

        final errorOut = await proc.stderrStream().toList();

        await expectLater(
          errorOut,
          containsAll(gcpProjectIdEnvironmentVariables),
        );
        await expectLater(proc.stdout, emitsDone);

        await proc.shouldExit(255);
      },
    );

    test('environment set', () async {
      final proc = await _run(
        projectIdPrint,
        environment: {
          gcpProjectIdEnvironmentVariables.first: 'test-project-42',
        },
      );

      await expectLater(proc.stdout, emits('test-project-42'));
      await expectLater(proc.stderr, emitsDone);

      await proc.shouldExit(0);
    });

    test('credentials file with project_id', () async {
      final tempDir = await Directory.systemTemp.createTemp('gcp_test');
      try {
        final credFile = File(
          '${tempDir.path}${Platform.pathSeparator}credentials.json',
        );
        await credFile.writeAsString('''
{
  "type": "service_account",
  "project_id": "test-project-from-file",
  "private_key_id": "key123",
  "private_key": "-----BEGIN PRIVATE KEY-----\\ntest\\n-----END PRIVATE KEY-----\\n",
  "client_email": "test@test-project.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token"
}
''');

        final proc = await _run(
          projectIdPrint,
          environment: {'GOOGLE_APPLICATION_CREDENTIALS': credFile.path},
        );

        await expectLater(proc.stdout, emits('test-project-from-file'));
        await expectLater(proc.stderr, emitsDone);

        await proc.shouldExit(0);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'environment variable takes precedence over credentials file',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('gcp_test');
        try {
          final credFile = File(
            '${tempDir.path}${Platform.pathSeparator}credentials.json',
          );
          await credFile.writeAsString('''
{
  "type": "service_account",
  "project_id": "test-project-from-file",
  "private_key_id": "key123"
}
''');

          final proc = await _run(
            projectIdPrint,
            environment: {
              gcpProjectIdEnvironmentVariables.first: 'test-project-from-env',
              'GOOGLE_APPLICATION_CREDENTIALS': credFile.path,
            },
          );

          await expectLater(proc.stdout, emits('test-project-from-env'));
          await expectLater(proc.stderr, emitsDone);

          await proc.shouldExit(0);
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      'credentials file without project_id',
      onPlatform: {'windows': const Skip('Cannot validate tests on windows.')},
      () async {
        final tempDir = await Directory.systemTemp.createTemp('gcp_test');
        try {
          final credFile = File(
            '${tempDir.path}${Platform.pathSeparator}credentials.json',
          );
          await credFile.writeAsString('''
{
  "type": "service_account",
  "private_key_id": "key123"
}
''');

          final proc = await _run(
            projectIdPrint,
            environment: {'GOOGLE_APPLICATION_CREDENTIALS': credFile.path},
          );

          final errorOut = await proc.stderrStream().toList();

          await expectLater(
            errorOut,
            containsAll(gcpProjectIdEnvironmentVariables),
          );
          await expectLater(proc.stdout, emitsDone);

          await proc.shouldExit(255);
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      'invalid credentials file path',
      onPlatform: {'windows': const Skip('Cannot validate tests on windows.')},
      () async {
        final proc = await _run(
          projectIdPrint,
          environment: {
            'GOOGLE_APPLICATION_CREDENTIALS': '/nonexistent/path/to/file.json',
          },
        );

        final errorOut = await proc.stderrStream().toList();

        await expectLater(
          errorOut,
          containsAll(gcpProjectIdEnvironmentVariables),
        );
        await expectLater(proc.stdout, emitsDone);

        await proc.shouldExit(255);
      },
    );

    test(
      'credentials file with malformed JSON',
      onPlatform: {'windows': const Skip('Cannot validate tests on windows.')},
      () async {
        final tempDir = await Directory.systemTemp.createTemp('gcp_test');
        try {
          final credFile = File(
            '${tempDir.path}${Platform.pathSeparator}credentials.json',
          );
          await credFile.writeAsString('not valid json at all');

          final proc = await _run(
            projectIdPrint,
            environment: {'GOOGLE_APPLICATION_CREDENTIALS': credFile.path},
          );

          final errorOut = await proc.stderrStream().toList();

          await expectLater(
            errorOut,
            containsAll(gcpProjectIdEnvironmentVariables),
          );
          await expectLater(proc.stdout, emitsDone);

          await proc.shouldExit(255);
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      'gcloud config with project_id',
      onPlatform: {'windows': const Skip('Cannot validate tests on windows.')},
      () async {
        final tempDir = await Directory.systemTemp.createTemp('gcp_test');
        try {
          // Create a mock gcloud script using Dart
          final mockGcloud = File(
            '${tempDir.path}${Platform.pathSeparator}gcloud',
          );
          await mockGcloud.writeAsString('''
#!${Platform.resolvedExecutable}
void main() {
  print('{"configuration": {"properties": {"core": {"project": "test-project-from-gcloud"}}}}');
}
''');
          await Process.run('chmod', ['+x', mockGcloud.path]);

          final proc = await _run(
            projectIdPrint,
            environment: {'PATH': tempDir.path},
          );

          await expectLater(proc.stdout, emits('test-project-from-gcloud'));
          await expectLater(proc.stderr, emitsDone);

          await proc.shouldExit(0);
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      'credentials file takes precedence over gcloud config',
      onPlatform: {'windows': const Skip('Cannot validate tests on windows.')},
      () async {
        final tempDir = await Directory.systemTemp.createTemp('gcp_test');
        try {
          final credFile = File(
            '${tempDir.path}${Platform.pathSeparator}credentials.json',
          );
          await credFile.writeAsString('''
{
  "type": "service_account",
  "project_id": "test-project-from-file"
}
''');

          // Create a mock gcloud script using Dart
          final mockGcloud = File(
            '${tempDir.path}${Platform.pathSeparator}gcloud',
          );
          await mockGcloud.writeAsString('''
#!${Platform.resolvedExecutable}
void main() {
  print('{"configuration": {"properties": {"core": {"project": "test-project-from-gcloud"}}}}');
}
''');
          await Process.run('chmod', ['+x', mockGcloud.path]);

          final proc = await _run(
            projectIdPrint,
            environment: {
              'GOOGLE_APPLICATION_CREDENTIALS': credFile.path,
              'PATH': tempDir.path,
            },
          );

          await expectLater(proc.stdout, emits('test-project-from-file'));
          await expectLater(proc.stderr, emitsDone);

          await proc.shouldExit(0);
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      'gcloud not found',
      onPlatform: {'windows': const Skip('Cannot validate tests on windows.')},
      () async {
        final proc = await _run(
          projectIdPrint,
          environment: {'PATH': '/nonexistent/path'},
        );

        final errorOut = await proc.stderrStream().toList();

        await expectLater(
          errorOut,
          containsAll(gcpProjectIdEnvironmentVariables),
        );
        await expectLater(proc.stdout, emitsDone);

        await proc.shouldExit(255);
      },
    );

    test(
      'gcloud returns non-zero exit code',
      onPlatform: {'windows': const Skip('Cannot validate tests on windows.')},
      () async {
        final tempDir = await Directory.systemTemp.createTemp('gcp_test');
        try {
          // Create a mock gcloud script that fails
          final mockGcloud = File(
            '${tempDir.path}${Platform.pathSeparator}gcloud',
          );
          await mockGcloud.writeAsString('''
#!${Platform.resolvedExecutable}
import 'dart:io';
void main() {
  stderr.writeln('ERROR: gcloud config error');
  exit(1);
}
''');
          await Process.run('chmod', ['+x', mockGcloud.path]);

          final proc = await _run(
            projectIdPrint,
            environment: {'PATH': tempDir.path},
          );

          final errorOut = await proc.stderrStream().toList();

          await expectLater(
            errorOut,
            containsAll(gcpProjectIdEnvironmentVariables),
          );
          await expectLater(proc.stdout, emitsDone);

          await proc.shouldExit(255);
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      'gcloud returns malformed JSON',
      onPlatform: {'windows': const Skip('Cannot validate tests on windows.')},
      () async {
        final tempDir = await Directory.systemTemp.createTemp('gcp_test');
        try {
          // Create a mock gcloud script that returns invalid JSON
          final mockGcloud = File(
            '${tempDir.path}${Platform.pathSeparator}gcloud',
          );
          await mockGcloud.writeAsString('''
#!${Platform.resolvedExecutable}
void main() {
  print('not valid json');
}
''');
          await Process.run('chmod', ['+x', mockGcloud.path]);

          final proc = await _run(
            projectIdPrint,
            environment: {'PATH': tempDir.path},
          );

          final errorOut = await proc.stderrStream().toList();

          await expectLater(
            errorOut,
            containsAll(gcpProjectIdEnvironmentVariables),
          );
          await expectLater(proc.stdout, emitsDone);

          await proc.shouldExit(255);
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      'gcloud returns JSON with missing configuration field',
      onPlatform: {'windows': const Skip('Cannot validate tests on windows.')},
      () async {
        final tempDir = await Directory.systemTemp.createTemp('gcp_test');
        try {
          // Create a mock gcloud script that returns JSON without configuration
          final mockGcloud = File(
            '${tempDir.path}${Platform.pathSeparator}gcloud',
          );
          await mockGcloud.writeAsString('''
#!${Platform.resolvedExecutable}
void main() {
  print('{"some": "data"}');
}
''');
          await Process.run('chmod', ['+x', mockGcloud.path]);

          final proc = await _run(
            projectIdPrint,
            environment: {'PATH': tempDir.path},
          );

          final errorOut = await proc.stderrStream().toList();

          await expectLater(
            errorOut,
            containsAll(gcpProjectIdEnvironmentVariables),
          );
          await expectLater(proc.stdout, emitsDone);

          await proc.shouldExit(255);
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      'gcloud returns JSON with missing project field',
      onPlatform: {'windows': const Skip('Cannot validate tests on windows.')},
      () async {
        final tempDir = await Directory.systemTemp.createTemp('gcp_test');
        try {
          // Create a mock gcloud that returns JSON without project
          final mockGcloud = File(
            '${tempDir.path}${Platform.pathSeparator}gcloud',
          );
          await mockGcloud.writeAsString('''
#!${Platform.resolvedExecutable}
void main() {
  print('{"configuration": {"properties": {"core": {}}}}');
}
''');
          await Process.run('chmod', ['+x', mockGcloud.path]);

          final proc = await _run(
            projectIdPrint,
            environment: {'PATH': tempDir.path},
          );

          final errorOut = await proc.stderrStream().toList();

          await expectLater(
            errorOut,
            containsAll(gcpProjectIdEnvironmentVariables),
          );
          await expectLater(proc.stdout, emitsDone);

          await proc.shouldExit(255);
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );

    test('computeProjectId caches and returns same value', () async {
      final tempDir = await Directory.systemTemp.createTemp('gcp_test');
      try {
        final credFile = File(
          '${tempDir.path}${Platform.pathSeparator}credentials.json',
        );
        await credFile.writeAsString('''
{
  "project_id": "original-cached-project"
}
''');

        // First call - should discover and cache
        final proc1 = await _run(
          'test/src/project_id_cache_print.dart',
          environment: {'GOOGLE_APPLICATION_CREDENTIALS': credFile.path},
        );

        await expectLater(
          proc1.stdout,
          emitsInOrder([
            'First call: original-cached-project',
            'Second call: original-cached-project',
            'CACHE_WORKS',
          ]),
        );
        await expectLater(proc1.stderr, emitsDone);
        await proc1.shouldExit(0);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    // TODO: worth emulating the metadata server?
  });

  group('listenPort', () {
    const listenPortPrint = 'test/src/listen_port_print.dart';

    test(
      'no environment',
      onPlatform: {
        'windows': const Skip('TODO: no idea why this is failing on windows'),
      },
      () async {
        final proc = await _run(listenPortPrint);

        await expectLater(proc.stderr, emitsDone);
        await expectLater(proc.stdout, emits('8080'));

        await proc.shouldExit(0);
      },
    );

    test('environment set', () async {
      final proc = await _run(listenPortPrint, environment: {'PORT': '8123'});

      await expectLater(proc.stderr, emitsDone);
      await expectLater(proc.stdout, emits('8123'));

      await proc.shouldExit(0);
    });
  });

  group(
    'waitForTerminate',
    onPlatform: {'windows': const Skip('Cannot validate tests on windows.')},
    () {
      const terminatePrint = 'test/src/terminate_print.dart';

      test('sigint', () async {
        final proc = await _run(terminatePrint);

        await expectLater(proc.stdout, emits('waiting for termination'));
        await Future<void>.delayed(const Duration(seconds: 1));
        proc.signal(ProcessSignal.sigint);
        await expectLater(
          proc.stdout,
          emitsInOrder([
            '',
            'Received signal SIGINT - closing',
            'done!',
            emitsDone,
          ]),
        );

        await proc.shouldExit(0);
      });

      test('sigterm', () async {
        final proc = await _run(terminatePrint);

        await expectLater(proc.stdout, emits('waiting for termination'));

        await Future<void>.delayed(const Duration(seconds: 1));

        proc.signal(ProcessSignal.sigterm);
        await expectLater(
          proc.stdout,
          emitsInOrder([
            '',
            'Received signal SIGTERM - closing',
            'done!',
            emitsDone,
          ]),
        );

        await proc.shouldExit(0);
      });
    },
  );
}

Future<TestProcess> _run(
  String dartScript, {
  Map<String, String>? environment,
}) => TestProcess.start(
  Platform.resolvedExecutable,
  [dartScript],
  environment: environment,
  includeParentEnvironment: false,
);
