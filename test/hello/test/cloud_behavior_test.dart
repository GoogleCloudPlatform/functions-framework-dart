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
import 'dart:async';
import 'dart:convert';

import 'package:functions_framework/functions_framework.dart';
import 'package:functions_framework/serve.dart';
import 'package:functions_framework/src/constants.dart';
import 'package:functions_framework/src/logging.dart';
import 'package:functions_framework/src/run.dart';
import 'package:hello_world_function_test/functions.dart';
import 'package:test/test.dart';

import 'src/test_utils.dart';

const _projectId = 'test_project_id';

void main() {
  final lines = <String>[];

  void expectLines(Object matcher) {
    try {
      expect(lines, matcher);
    } finally {
      lines.clear();
    }
  }

  Completer<bool> completionSignal;
  Future<void> runFuture;
  int port;
  Map<String, String> headers;
  var count = 0;
  String traceStart;

  Future<void> doSetup(FunctionTarget endpoint) async {
    lines.clear();
    completionSignal = Completer<bool>.sync();

    runFuture = runZoned(
      () => run(
        0,
        endpoint.handler,
        completionSignal.future,
        cloudLoggingMiddleware(_projectId),
      ),
      zoneSpecification: ZoneSpecification(
        print: (_, __, ___, line) => lines.add(line),
      ),
    );

    // wait for the server to start!
    await Future.value();

    final listeningLine = lines.single;
    lines.clear();
    final split = listeningLine.split(':');
    expect(split.first, 'Listening on ');
    port = int.parse(split.last);

    count++;
    traceStart = 'trace_start$count';

    headers = {cloudTraceContextHeader: '$traceStart/trace_end'};
  }

  tearDown(() async {
    completionSignal.complete(false);

    await runFuture;
  });

  void matchEntry(
    String entry,
    String message, {
    LogSeverity severity = LogSeverity.info,
  }) {
    final map = jsonDecode(entry) as Map<String, dynamic>;

    expect(
      map,
      {
        'message': message,
        'severity': severity.name,
        'logging.googleapis.com/trace':
            'projects/test_project_id/traces/$traceStart'
      },
    );
  }

  void validateCloudErrorOutput(
    Map<String, dynamic> map,
    Object messageMatcher,
    Object fileMatcher,
    Object functionMatcher, {
    String severity = 'ERROR',
    bool containsLine = true,
  }) {
    expect(map, hasLength(4));
    expect(map, containsPair('severity', severity));
    expect(
      map,
      containsPair(
        'message',
        messageMatcher,
      ),
    );
    expect(
      map,
      containsPair(
        'logging.googleapis.com/trace',
        'projects/$_projectId/traces/$traceStart',
      ),
    );

    final sourceLocation =
        map['logging.googleapis.com/sourceLocation'] as Map<String, dynamic>;

    expect(
      sourceLocation,
      containsPair(
        'file',
        fileMatcher,
      ),
    );

    if (containsLine) {
      expect(
        sourceLocation,
        containsPair(
          'line',
          isA<String>(), // spec says this should be a String
        ),
      );
    } else {
      expect(sourceLocation, isNot(contains('line')));
    }
    expect(sourceLocation, containsPair('function', functionMatcher));
  }

  group('cloud event', () {
    setUp(() async {
      await doSetup(
        FunctionTarget.cloudEventWithContext(
          basicCloudEventHandler,
        ),
      );
    });

    Future<void> _post(
      String path, {
      String requestBody,
      int expectedStatusCode = 200,
      String expectedBody,
    }) async {
      final response = await post(
        'http://localhost:$port/$path',
        headers: headers,
        body: requestBody,
      );

      expect(
        response.statusCode,
        expectedStatusCode,
        reason: 'response.statusCode',
      );
      expect(response.body, expectedBody ?? isEmpty, reason: 'response.body');
    }

    test('no content type causes a 400', () async {
      await _post(
        '',
        expectedStatusCode: 400,
        expectedBody: 'Bad request. Content-Type header is required.',
      );

      expect(lines, hasLength(1));
      final map = jsonDecode(lines.single) as Map<String, dynamic>;
      validateCloudErrorOutput(
        map,
        startsWith('Bad request. Content-Type header is required.'),
        'package:functions_framework/src/json_request_utils.dart',
        'mediaTypeFromRequest',
        severity: 'WARNING',
      );
      lines.clear();
    });

    test('bad format of core header: missing source', () async {
      headers['Content-Type'] = 'application/json';
      await _post(
        '',
        expectedStatusCode: 400,
        requestBody: r'''
{
  "specversion": "1.0",
  "type": "google.cloud.pubsub.topic.publish",
  "time": "2020-09-05T03:56:24.000Z",
  "id": "1234-1234-1234",
  "data": {
    "subscription": "projects/my-project/subscriptions/my-subscription",
    "message": {
      "@type": "type.googleapis.com/google.pubsub.v1.PubsubMessage",
      "attributes": {
        "attr1":"attr1-value"
      },
      "data": "dGVzdCBtZXNzYWdlIDM="
    }
  }
}''',
        expectedBody: 'Bad request. Could not decode the request as a '
            'structured-mode message.',
      );

      expect(lines, hasLength(1));
      final map = jsonDecode(lines.single) as Map<String, dynamic>;
      validateCloudErrorOutput(
        map,
        startsWith(
          'Bad request. Could not decode the request as a '
          'structured-mode message.',
        ),
        startsWith('package:functions_framework/src/'),
        isNotEmpty,
        severity: 'WARNING',
      );
      lines.clear();
    });
  });

  group('http', () {
    setUp(() async {
      await doSetup(FunctionTarget.http(function));
    });

    Future<void> _get(
      String path, {
      int expectedStatusCode = 200,
      Object bodyMatcher,
    }) async {
      if (bodyMatcher == null && expectedStatusCode == 500) {
        bodyMatcher = 'Internal Server Error';
      }

      final response = await get(
        'http://localhost:$port/$path',
        headers: headers,
      );

      expect(response.statusCode, expectedStatusCode);
      expect(response.body, bodyMatcher ?? isEmpty);
    }

    test('root', () async {
      await _get('', bodyMatcher: 'Hello, World!');
      expectLines(isEmpty);
    });

    test('info', () async {
      await _get('info', bodyMatcher: isNotEmpty);
      expectLines(isEmpty);
    });

    test('print', () async {
      await _get('print/something', bodyMatcher: 'Printing: print/something');
      expect(lines, hasLength(2));

      matchEntry(lines[0], 'print');
      matchEntry(lines[1], 'something');

      lines.clear();
    });

    test('error', () async {
      await _get('error', expectedStatusCode: 500);

      expect(lines, hasLength(1));
      final entry = lines.single;
      final map = jsonDecode(entry) as Map<String, dynamic>;
      validateCloudErrorOutput(
        map,
        startsWith('Exception: An error was forced by requesting "error"'),
        'package:hello_world_function_test/functions.dart',
        'function',
      );
      lines.clear();
    });

    test('async error', () async {
      await _get('error/async', expectedStatusCode: 500);

      expect(lines, hasLength(2));

      validateCloudErrorOutput(
        jsonDecode(lines[0]) as Map<String, dynamic>,
        startsWith(
          'Exception: An error was forced by requesting "error/async"',
        ),
        'package:hello_world_function_test/functions.dart',
        'function',
      );

      validateCloudErrorOutput(
        jsonDecode(lines[1]) as Map<String, dynamic>,
        startsWith(
          'Bad state: async error',
        ),
        'package:hello_world_function_test/functions.dart',
        'function.<fn>',
      );

      lines.clear();
    });
  });

  group('logging', () {
    setUp(() async {
      await doSetup(
        FunctionTarget.httpWithLogger(loggingHandler),
      );
    });

    Future<void> _get(
      String path, {
      int expectedStatusCode = 200,
      Object bodyMatcher,
    }) async {
      if (bodyMatcher == null && expectedStatusCode == 500) {
        bodyMatcher = 'Internal Server Error';
      }

      final response = await get(
        'http://localhost:$port/$path',
        headers: headers,
      );

      expect(response.statusCode, expectedStatusCode);
      expect(response.body, bodyMatcher ?? isEmpty);
    }

    test('all levels in and out of zone', () async {
      await _get('');
      final trace = 'projects/test_project_id/traces/$traceStart';
      expectLines([
        '{"message":"default","severity":"DEFAULT","logging.googleapis.com/trace":"$trace"}',
        '{"message":"debug","severity":"DEBUG","logging.googleapis.com/trace":"$trace"}',
        '{"message":"info","severity":"INFO","logging.googleapis.com/trace":"$trace"}',
        '{"message":"notice","severity":"NOTICE","logging.googleapis.com/trace":"$trace"}',
        '{"message":"warning","severity":"WARNING","logging.googleapis.com/trace":"$trace"}',
        '{"message":"error","severity":"ERROR","logging.googleapis.com/trace":"$trace"}',
        '{"message":"critical","severity":"CRITICAL","logging.googleapis.com/trace":"$trace"}',
        '{"message":"alert","severity":"ALERT","logging.googleapis.com/trace":"$trace"}',
        '{"message":"emergency","severity":"EMERGENCY","logging.googleapis.com/trace":"$trace"}'
      ]);
    });
  });
}
