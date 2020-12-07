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

import 'package:functions_framework/src/constants.dart';
import 'package:functions_framework/src/logging.dart';
import 'package:functions_framework/src/run.dart';
import 'package:hello_world_function_test/library.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

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
  Map<String, String> _headers;
  var count = 0;
  String traceStart;

  setUp(() async {
    lines.clear();
    completionSignal = Completer<bool>.sync();

    runFuture = runZoned(
      () => run(
        0,
        handleGet,
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

    _headers = {cloudTraceContextHeader: '$traceStart/trace_end'};
  });

  tearDown(() async {
    completionSignal.complete(false);

    await runFuture;
  });

  Future<void> _get(
    String path, {
    int expectedStatusCode = 200,
  }) async {
    final response = await get(
      'http://localhost:$port/$path',
      headers: _headers,
    );

    expect(response.statusCode, expectedStatusCode);
  }

  test('root', () async {
    await _get('');
    expectLines(isEmpty);
  });

  test('info', () async {
    await _get('info');
    expectLines(isEmpty);
  });

  test('print', () async {
    await _get('print/something');
    expect(lines, hasLength(2));

    void matchEntry(String entry, String message) {
      final map = jsonDecode(entry) as Map<String, dynamic>;

      expect(
        map,
        {
          'message': message,
          'severity': 'INFO',
          'logging.googleapis.com/trace':
              'projects/test_project_id/traces/trace_start3'
        },
      );
    }

    matchEntry(lines[0], 'print');
    matchEntry(lines[1], 'something');

    lines.clear();
  });

  test('error', () async {
    await _get('error', expectedStatusCode: 500);

    expect(lines, hasLength(1));
    final entry = lines.single;
    final map = jsonDecode(entry) as Map<String, dynamic>;

    expect(map, hasLength(4));
    expect(map, containsPair('severity', 'ERROR'));
    expect(
      map,
      containsPair('message', startsWith('Exception: An error was forced')),
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
      containsPair('file', 'package:hello_world_function_test/library.dart'),
    );
    expect(
      sourceLocation,
      containsPair(
        'line',
        isA<String>(), // spec says this should be a String
      ),
    );
    expect(sourceLocation, containsPair('function', 'handleGet'));

    lines.clear();
  });

  test('async error', () async {
    void expectLine(String entry) {
      final map = jsonDecode(entry) as Map<String, dynamic>;

      expect(map, hasLength(4));
      expect(map, containsPair('severity', 'ERROR'));
      expect(
        map,
        containsPair(
          'message',
          anyOf(
            startsWith(
              'Exception: An error was forced by requesting "error/async"',
            ),
            startsWith('Bad state: async error'),
          ),
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
        containsPair('file', 'package:hello_world_function_test/library.dart'),
      );
      expect(
        sourceLocation,
        containsPair(
          'line',
          isA<String>(), // spec says this should be a String
        ),
      );
      expect(
        sourceLocation,
        containsPair(
          'function',
          startsWith('handleGet'),
        ),
      );
    }

    await _get('error/async', expectedStatusCode: 500);

    expect(lines, hasLength(2));

    expectLine(lines[0]);
    expectLine(lines[1]);

    lines.clear();
  });
}
