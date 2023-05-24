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

@Timeout(Duration(seconds: 3))
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

import 'src/test_utils.dart';

Future<TestProcess> _startServerTest() =>
    startServerTest(expectedListeningPort: 0);

void main() {
  group('not found assets', () {
    for (var item in const {'robots.txt', 'favicon.ico'}) {
      test('404 for $item', () async {
        final proc = await _startServerTest();

        final response = await get('http://localhost:$autoPort/$item');
        expect(response.statusCode, 404);
        expect(response.body, 'Not found.');

        await finishServerTest(
          proc,
          requestOutput: endsWith('GET     [404] /$item'),
        );
      });
    }
  });

  group('special handlers', () {
    test('info', () async {
      final proc = await _startServerTest();

      final requestUrl = 'http://localhost:$autoPort/info';
      final response = await get(requestUrl);
      expect(response.statusCode, 200);
      final responseBody = response.body;
      final jsonBody = jsonDecode(responseBody) as Map<String, dynamic>;
      expect(jsonBody, containsPair('request', requestUrl));
      expect(jsonBody, contains('headers'));
      expect(jsonBody, contains('environment'));

      await finishServerTest(
        proc,
        requestOutput: endsWith('GET     [200] /info'),
      );
    });

    test('print', () async {
      final proc = await _startServerTest();

      const requestedPath = 'print/something/here';
      final requestUrl = 'http://localhost:$autoPort/$requestedPath';
      final response = await get(requestUrl);
      expect(response.statusCode, 200);

      const expectedOutput = 'Printing: $requestedPath';
      expect(response.body, expectedOutput);

      await finishServerTest(
        proc,
        requestOutput: emitsInOrder(
          [
            'print',
            'something',
            'here',
            endsWith('GET     [200] /$requestedPath'),
          ],
        ),
      );
    });

    test('error', () async {
      final proc = await _startServerTest();

      final response = await get('http://localhost:$autoPort/error');
      expect(response.statusCode, 500);
      expect(response.body, 'Internal Server Error');

      await expectLater(
        proc.stderr,
        emitsInOrder([
          startsWith('ERROR -'),
          'GET /error',
          'Error thrown by handler.',
          'Exception: An error was forced by requesting "error"',
        ]),
      );

      await finishServerTest(proc, requestOutput: isEmpty);
    });

    test('BadRequestException', () async {
      final proc = await _startServerTest();

      final response = await get('http://localhost:$autoPort/exception');
      expect(response.statusCode, 400);
      expect(response.body, 'Bad request. Testing `throw BadRequestException`');

      await expectLater(
        proc.stderr,
        emitsInOrder([
          'Testing `throw BadRequestException` (400)',
          startsWith('package:hello_world_function_test/functions.dart'),
        ]),
      );

      await finishServerTest(
        proc,
        requestOutput: emitsInOrder([
          endsWith('GET     [400] /exception'),
        ]),
      );
    });

    test('async error', () async {
      final proc = await _startServerTest();

      final response = await get('http://localhost:$autoPort/error/async');
      expect(response.statusCode, 500);
      expect(response.body, 'Internal Server Error');

      await expectLater(
        proc.stderr,
        emitsInOrder([
          startsWith('ERROR -'),
          'GET /error/async',
          'Error thrown by handler.',
          'Exception: An error was forced by requesting "error/async"',
          // Need the `mayEmitMultiple` here because Dart 2.10 and Dart 2.12
          // behave differently
          mayEmitMultiple(startsWith('package:')),
          '',
          startsWith('ERROR -'),
          'Asynchronous error',
          'Bad state: async error',
          startsWith('package:hello_world_function_test/functions.dart'),
        ]),
      );

      await finishServerTest(proc, requestOutput: isEmpty);
    });
  });
}
