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

@TestOn('vm')
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:stagehand/stagehand.dart';
import 'package:stagehand/src/cli_app.dart';
import 'package:test/test.dart';
import 'package:usage/usage.dart';

void main() {
  group('cli', () {
    CliApp app;
    CliLoggerMock logger;
    GeneratorTargetMock target;

    setUp(() {
      logger = CliLoggerMock();
      target = GeneratorTargetMock();
      app = CliApp(generators, logger, target);
      app.cwd = Directory('test');
      app.analytics = AnalyticsMock();
    });

    void _expectOk([_]) {
      expect(logger.getStderr(), isEmpty);
      expect(logger.getStdout(), isNot(isEmpty));
    }

    Future _expectError(Future f, [bool hasStdout = true]) {
      return f.then((_) => fail('error expected')).catchError((e) {
        expect(logger.getStderr(), isNot(isEmpty));
        if (hasStdout) {
          expect(logger.getStdout(), isNot(isEmpty));
        } else {
          expect(logger.getStdout(), isEmpty);
        }
      });
    }

    test('no args', () {
      return app.process([]).then(_expectOk);
    });

    test('one arg', () {
      return app.process(['console-full']).then((_) {
        _expectOk();
        expect(target.createdCount, isPositive);
      });
    });

    test('one arg (bad)', () {
      return _expectError(app.process(['bad_generator']));
    });

    test('two args', () {
      return _expectError(app.process(['consoleapp', 'foobar']));
    });

    group('machine format', () {
      test('returns a list of results', () async {
        await app.process(['--machine']);
        _expectOk();
        List results = jsonDecode(logger.getStdout());
        expect(results, isNotEmpty);
      });

      test('includes categories', () async {
        await app.process(['--machine']);
        _expectOk();
        List results = jsonDecode(logger.getStdout());

        var consoleFull =
            results.singleWhere((item) => item['name'] == 'console-full');
        expect(consoleFull, isNotNull);
        expect(
          consoleFull['categories'],
          allOf(isNotNull, isList, contains('dart'), contains('console')),
        );
      });
    });

    test('version', () {
      return app.process(['--version']).then((_) {
        _expectOk();
        expect(logger.getStdout(), contains('stagehand version'));
      });
    });
  });
}

class CliLoggerMock implements CliLogger {
  final StringBuffer _stdout = StringBuffer();
  final StringBuffer _stderr = StringBuffer();

  @override
  void stderr(String message) => _stderr.write(message);

  @override
  void stdout(String message) => _stdout.write(message);

  String getStdout() => _stdout.toString();
  String getStderr() => _stderr.toString();
}

class GeneratorTargetMock implements GeneratorTarget {
  int createdCount = 0;

  @override
  Future createFile(String path, List<int> contents) {
    expect(contents, isNot(isEmpty));
    expect(path, isNot(startsWith('/')));

    createdCount++;

    return Future.value();
  }
}
