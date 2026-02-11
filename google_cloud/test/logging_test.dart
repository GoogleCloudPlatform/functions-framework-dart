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

import 'dart:async';
import 'dart:convert';

import 'package:google_cloud/general.dart';
import 'package:google_cloud/http_serving.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('structuredLogEntry', () {
    test('simple message', () {
      final entry = structuredLogEntry('hello', LogSeverity.info);
      final map = jsonDecode(entry) as Map<String, dynamic>;
      expect(map, containsPair('message', 'hello'));
      expect(map, containsPair('severity', 'INFO'));
    });

    test('message with traceId', () {
      final entry = structuredLogEntry(
        'hello',
        LogSeverity.info,
        traceId: 'trace-123',
      );
      final map = jsonDecode(entry) as Map<String, dynamic>;
      expect(map, containsPair('message', 'hello'));
      expect(map, containsPair('severity', 'INFO'));
      expect(map, containsPair('logging.googleapis.com/trace', 'trace-123'));
    });

    test('json encodable message', () {
      final message = {'foo': 'bar', 'count': 42};
      final entry = structuredLogEntry(message, LogSeverity.info);
      final map = jsonDecode(entry) as Map<String, dynamic>;
      expect(map, containsPair('message', message));
      expect(map, containsPair('severity', 'INFO'));
    });

    test('non-encodable message is stringified', () {
      final message = _NonEncodable();
      final entry = structuredLogEntry(message, LogSeverity.info);
      final map = jsonDecode(entry) as Map<String, dynamic>;
      expect(map, containsPair('message', 'I am not encodable'));
      expect(map, containsPair('severity', 'INFO'));
    });
  });

  group('LogSeverity', () {
    test('toJson returns name', () {
      expect(LogSeverity.info.toJson(), 'INFO');
      expect(LogSeverity.error.toJson(), 'ERROR');
    });

    test('comparable', () {
      expect(LogSeverity.info.compareTo(LogSeverity.error), isNegative);
      expect(LogSeverity.critical.compareTo(LogSeverity.warning), isPositive);
    });
  });

  group('RequestLogger (default)', () {
    test('log with default severity', () {
      final output = <String>[];
      runZoned(
        () => currentLogger.log('hello', LogSeverity.defaultSeverity),
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => output.add(line),
        ),
      );
      expect(output, ['hello']);
    });

    test('log with explicit severity', () {
      final output = <String>[];
      runZoned(
        () => currentLogger.log('hello', LogSeverity.error),
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => output.add(line),
        ),
      );
      expect(output, ['ERROR: hello']);
    });
  });

  group('middleware', () {
    test('cloudLoggingMiddleware logs structured entries', () async {
      final output = <String>[];
      final handler = const Pipeline()
          .addMiddleware(cloudLoggingMiddleware('test-project'))
          .addHandler((request) {
            currentLogger.info('inner log');
            return Response.ok('done');
          });

      await runZoned(
        () => handler(
          Request(
            'GET',
            Uri.parse('http://localhost/'),
            headers: {'x-cloud-trace-context': 'trace-456/123;o=1'},
          ),
        ),
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => output.add(line),
        ),
      );

      expect(output, hasLength(1));
      final map = jsonDecode(output.single) as Map<String, dynamic>;
      expect(map, containsPair('message', 'inner log'));
      expect(map, containsPair('severity', 'INFO'));
      expect(
        map,
        containsPair(
          'logging.googleapis.com/trace',
          'projects/test-project/traces/trace-456',
        ),
      );
    });

    test('badRequestMiddleware handles BadRequestException', () async {
      final handler = const Pipeline()
          .addMiddleware(badRequestMiddleware)
          .addHandler((request) {
            throw BadRequestException(400, 'Custom bad request');
          });

      final response = await handler(
        Request('GET', Uri.parse('http://localhost/')),
      );
      expect(response.statusCode, 400);
      expect(
        await response.readAsString(),
        contains('Bad request. Custom bad request'),
      );
    });
  });

  group('BadRequestException', () {
    test('valid status code', () {
      final ex = BadRequestException(400, 'Bad');
      expect(ex.statusCode, 400);
      expect(ex.message, 'Bad');
      expect(ex.toString(), 'Bad (400)');
    });

    test('invalid status code low', () {
      expect(() => BadRequestException(399, 'Bad'), throwsArgumentError);
    });

    test('invalid status code high', () {
      expect(() => BadRequestException(500, 'Bad'), throwsArgumentError);
    });

    test('empty message', () {
      // ignore: prefer_const_constructors
      expect(
        () => BadRequestException(400, ''),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

class _NonEncodable {
  @override
  String toString() => 'I am not encodable';
}
