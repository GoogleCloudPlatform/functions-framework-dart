@Timeout(Duration(seconds: 3))
import 'dart:convert';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

import 'src/test_utils.dart';

void main() {
  group('binary-mode message', () {
    test('valid input', () async {
      final proc = await _hostCloudEventHandler();

      const body = r'''
{
 "subscription": "projects/my-project/subscriptions/my-subscription",
 "message": {
   "@type": "type.googleapis.com/google.pubsub.v1.PubsubMessage",
   "attributes": {
     "attr1":"attr1-value"
   },
   "data": "dGVzdCBtZXNzYWdlIDM="
 }
}''';

      final response = await _makeRequest(
        body,
        {
          'Content-Type': 'application/json; charset=utf-8',
          'ce-specversion': '1.0',
          'ce-type': 'google.cloud.pubsub.topic.publish',
          'ce-time': '2020-09-05T03:56:24Z',
          'ce-id': '1234-1234-1234',
          'ce-source': 'urn:uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66',
        },
      );
      expect(response.statusCode, 200);
      expect(response.body, isEmpty);

      await finishServerTest(
        proc,
        requestOutput: matches(finishedPattern('POST', 200)),
      );

      final stderrOutput = await proc.stderrStream().join('\n');
      final json = jsonDecode(stderrOutput) as Map<String, dynamic>;

      expect(
        json,
        {
          'id': '1234-1234-1234',
          'specversion': '1.0',
          'type': 'google.cloud.pubsub.topic.publish',
          'datacontenttype': 'application/json; charset=utf-8',
          'time': '2020-09-05T03:56:24.000Z',
          'source': 'urn:uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66',
          'data': jsonDecode(body),
        },
      );
    });
  });

  group('structured-mode message', () {
    test('valid request', () async {
      final proc = await _hostCloudEventHandler();

      const body = r'''
{
  "specversion": "1.0",
  "type": "google.cloud.pubsub.topic.publish",
  "time": "2020-09-05T03:56:24.000Z",
  "id": "1234-1234-1234",
  "source": "urn:uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66",
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
}''';
      final response = await _makeRequest(body, {
        'Content-Type': 'application/json; charset=utf-8',
      });
      expect(response.statusCode, 200);
      expect(response.body, isEmpty);

      await finishServerTest(
        proc,
        requestOutput: matches(finishedPattern('POST', 200)),
      );

      final stderrOutput = await proc.stderrStream().join('\n');

      final json = jsonDecode(stderrOutput) as Map<String, dynamic>;

      expect(
        json,
        {
          ...jsonDecode(body) as Map<String, dynamic>,
          'datacontenttype': 'application/json; charset=utf-8',
        },
      );
    });
  });
}

Future<Response> _makeRequest(String body, Map<String, String> headers) async {
  final requestUrl = 'http://localhost:$autoPort/';

  final response = await post(
    requestUrl,
    body: body,
    headers: headers,
  );
  return response;
}

Future<TestProcess> _hostCloudEventHandler() async {
  final proc = await startServerTest(
    arguments: [
      '--signature-type',
      'cloudevent',
    ],
    expectedListeningPort: 0,
  );
  return proc;
}
