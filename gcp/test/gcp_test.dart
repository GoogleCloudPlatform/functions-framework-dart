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

import 'package:gcp/gcp.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  group('currentProjectId', () {
    const projectIdPrint = 'test/src/project_id_print.dart';

    test('not environment', () async {
      final proc = await _run(projectIdPrint);

      final errorOut = await proc.stderrStream().toList();

      await expectLater(
        errorOut,
        containsAll(gcpProjectIdEnvironmentVariables),
      );
      await expectLater(proc.stdout, emitsDone);

      await proc.shouldExit(255);
    });

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
      final proc = await _run(
        listenPortPrint,
        environment: {'PORT': '8123'},
      );

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

  group('currentRegion', () {
    const regionPrint = 'test/src/region_print.dart';

    test(
      'not environment',
      onPlatform: const {'windows': Skip('Broken on windows')},
      () async {
        final proc = await _run(regionPrint);

        final errorOut = await proc.stderrStream().toList();

        await expectLater(
          errorOut,
          containsAll(MetadataValue.region.environmentValues),
        );
        await expectLater(proc.stdout, emitsDone);

        await proc.shouldExit(255);
      },
    );

    test('environment set', () async {
      final proc = await _run(
        regionPrint,
        environment: {
          MetadataValue.region.environmentValues.first: 'us-central1',
        },
      );

      await expectLater(proc.stdout, emits('us-central1'));
      await expectLater(proc.stderr, emitsDone);

      await proc.shouldExit(0);
    });

    // TODO: worth emulating the metadata server?
  });
}

Future<TestProcess> _run(
  String dartScript, {
  Map<String, String>? environment,
}) =>
    TestProcess.start(
      Platform.resolvedExecutable,
      [dartScript],
      environment: environment,
      includeParentEnvironment: false,
    );
