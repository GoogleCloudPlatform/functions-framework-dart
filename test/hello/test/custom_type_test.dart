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
import 'dart:convert';

import 'package:hello_world_function_test/functions.dart';
import 'package:http/http.dart' show Response;
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

import 'src/test_utils.dart';

void main() {
  TestProcess testProcess;

  Future<void> expectInvalid(
    Response response,
    String errorMessage, {
    Object extraPrintMatcher,
  }) async {
    expect(response.statusCode, 400);
    expect(
      response.headers,
      containsTextPlainHeader,
    );
    expect(
      response.body,
      'Bad request. $errorMessage',
    );

    await expectLater(
      testProcess.stderr,
      emitsInOrder([
        '[BAD REQUEST] POST	/',
        '$errorMessage (400)',
      ]),
    );

    await finishServerTest(
      testProcess,
      requestOutput: emitsInOrder([
        if (extraPrintMatcher != null) extraPrintMatcher,
        endsWith('POST    [400] /'),
      ]),
    );
  }

  void testInvalid() {
    test('missing JSON content type', () async {
      final requestUrl = 'http://localhost:$autoPort/';
      final response = await post(
        requestUrl,
        headers: {
          'Content-Type': 'application/text',
        },
        body: '{"a":1}',
      );
      await expectInvalid(
        response,
        'Unsupported encoding "application/text; charset=utf-8". '
        'Only "application/json" is supported.',
      );
    });

    test('body is not JSON', () async {
      final requestUrl = 'http://localhost:$autoPort/';
      final response = await post(
        requestUrl,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: 'not json!',
      );

      await expectInvalid(
        response,
        'Could not parse the request body as JSON.',
      );
    });

    test('body is the wrong shape of JSON', () async {
      final requestUrl = 'http://localhost:$autoPort/';
      final response = await post(
        requestUrl,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: '[]',
      );

      await expectInvalid(
        response,
        'The provided JSON is not the expected type `Map<String, dynamic>`.',
      );
    });
  }

  tearDown(() {
    testProcess = null;
  });

  group('pubSubHandler handler', () {
    setUp(() async {
      testProcess = await startServerTest(
        env: {
          'FUNCTION_TARGET': 'pubSubHandler', // overridden by --target
        },
        expectedListeningPort: 0,
      );
    });

    group('valid', () {
      test('correct', () async {
        const subscription = 'subABC123';
        final requestUrl = 'http://localhost:$autoPort/';
        final response = await post(
          requestUrl,
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: jsonEncode(
            PubSub(
              PubSubMessage(
                'data',
                'messageId',
                DateTime.now(),
                {},
              ),
              subscription,
            ),
          ),
        );

        expect(response.statusCode, 200);
        expect(
          response.headers,
          allOf(
            containsTextPlainHeader,
            containsPair('subscription', subscription),
            containsPair('multi', 'item1, item2'),
          ),
        );
        expect(response.body, isEmpty);

        await finishServerTest(
          testProcess,
          requestOutput: emitsInOrder([
            'subscription: $subscription',
            'INFO: subscription: $subscription',
            endsWith('POST    [200] /'),
          ]),
        );
      });
    });

    group('invalid', () {
      testInvalid();

      test('missing message', () async {
        final requestUrl = 'http://localhost:$autoPort/';
        final response = await post(
          requestUrl,
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: '{"a":1}',
        );

        await expectInvalid(
          response,
          'A message is required!',
          extraPrintMatcher: emitsInOrder([
            'subscription: null',
            'INFO: subscription: null',
          ]),
        );
      });
    });
  });

  group('JSON handler', () {
    setUp(() async {
      testProcess = await startServerTest(
        env: {
          'FUNCTION_TARGET': 'jsonHandler', // overridden by --target
        },
        expectedListeningPort: 0,
      );
    });

    group('valid', () {
      test('with keys', () async {
        final requestUrl = 'http://localhost:$autoPort/';
        final response = await post(
          requestUrl,
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: '{"a":1}',
        );
        expect(response.statusCode, 200);
        expect(
          response.headers,
          allOf(
            containsPair('content-type', 'application/json'),
            containsPair('key_count', '1'),
            containsPair('multi', 'item1, item2'),
          ),
        );
        final jsonBody = jsonDecode(response.body);
        expect(jsonBody, false);

        await finishServerTest(
          testProcess,
          requestOutput: emitsInOrder([
            'Keys: a',
            endsWith('POST    [200] /'),
          ]),
        );
      });

      test('without keys', () async {
        final requestUrl = 'http://localhost:$autoPort/';
        final response = await post(
          requestUrl,
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: '{}',
        );
        expect(response.statusCode, 200);
        expect(
          response.headers,
          allOf(
            containsPair('content-type', 'application/json'),
            containsPair('key_count', '0'),
            containsPair('multi', 'item1, item2'),
          ),
        );
        final jsonBody = jsonDecode(response.body);
        expect(jsonBody, true);

        await finishServerTest(
          testProcess,
          requestOutput: emitsInOrder([
            'Keys: ',
            endsWith('POST    [200] /'),
          ]),
        );
      });
    });

    group('invalid', testInvalid);
  });
}
