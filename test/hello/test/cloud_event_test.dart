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

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

import 'src/test_utils.dart';

void main() {
  // TODO: non-JSON body
  // TODO: JSON-body, but not a Map
  // TODO: JSON-body is a map, but wrong/missing keys/values
  // TODO: invalid header value encoding (bad date time, for instance)
  // TODO: proper error logging when hosted on cloud

  group('binary-mode message', () {
    test('valid input', () async {
      final proc = await _hostBasicEventHandler();

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
        requestOutput: endsWith('POST    [200] /'),
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

    test('bad format of core header: time', () async {
      final stderrOutput = await _makeBadRequest(
        r'''
{
 "subscription": "projects/my-project/subscriptions/my-subscription",
 "message": {
   "@type": "type.googleapis.com/google.pubsub.v1.PubsubMessage",
   "attributes": {
     "attr1":"attr1-value"
   },
   "data": "dGVzdCBtZXNzYWdlIDM="
 }
}''',
        {
          'Content-Type': 'application/json; charset=utf-8',
          'ce-specversion': '1.0',
          'ce-type': 'google.cloud.pubsub.topic.publish',
          'ce-time': 'bad time!',
          'ce-id': '1234-1234-1234',
          'ce-source': 'urn:uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66',
        },
        'binary-mode message',
      );
      expect(
        stderrOutput,
        startsWith(
          'Could not decode the request as a binary-mode message. (400)\n'
          'CheckedFromJsonException\n'
          'Could not create `CloudEvent`.\n'
          'There is a problem with "time".\n'
          'Invalid date format\n',
        ),
      );
    });

    test('bad format of core header: missing ce-source', () async {
      final stderrOutput = await _makeBadRequest(
        r'''
{
 "subscription": "projects/my-project/subscriptions/my-subscription",
 "message": {
   "@type": "type.googleapis.com/google.pubsub.v1.PubsubMessage",
   "attributes": {
     "attr1":"attr1-value"
   },
   "data": "dGVzdCBtZXNzYWdlIDM="
 }
}''',
        {
          'Content-Type': 'application/json; charset=utf-8',
          'ce-specversion': '1.0',
          'ce-type': 'google.cloud.pubsub.topic.publish',
          'ce-time': 'bad time!',
          'ce-id': '1234-1234-1234',
        },
        'structured-mode message',
      );
      expect(
        stderrOutput,
        startsWith(
          // NOTE! Since binary-mode failed, we fallback to structured mode!
          'Could not decode the request as a structured-mode message. (400)\n'
          'CheckedFromJsonException\n'
          'Could not create `CloudEvent`.\n'
          'There is a problem with "id".\n'
          'Required keys are missing: id, source, specversion, type.\n',
        ),
      );
    });
  });

  group('structured-mode message', () {
    test('valid request', () async {
      final proc = await _hostBasicEventHandler();

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
        requestOutput: endsWith('POST    [200] /'),
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

    test('bad format of core header: time', () async {
      final stderrOutput = await _makeBadRequest(
        r'''
{
  "specversion": "1.0",
  "type": "google.cloud.pubsub.topic.publish",
  "source": "urn:uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66",
  "time": "bad time",
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
        {
          'Content-Type': 'application/json; charset=utf-8',
        },
        'structured-mode message',
      );
      expect(
        stderrOutput,
        startsWith(
          'Could not decode the request as a structured-mode message. (400)\n'
          'CheckedFromJsonException\n'
          'Could not create `CloudEvent`.\n'
          'There is a problem with "time".\n'
          'Invalid date format\n',
        ),
      );
    });

    test('bad format of core header: missing source', () async {
      final stderrOutput = await _makeBadRequest(
        r'''
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
        {
          'Content-Type': 'application/json; charset=utf-8',
        },
        'structured-mode message',
      );
      expect(
        stderrOutput,
        startsWith(
          'Could not decode the request as a structured-mode message. (400)\n'
          'CheckedFromJsonException\n'
          'Could not create `CloudEvent`.\n'
          'There is a problem with "source".\n'
          'Required keys are missing: source.\n',
        ),
      );
    });
  });
}

Future<String> _makeBadRequest(
  String body,
  Map<String, String> headers,
  String messageType,
) async {
  final proc = await _hostBasicEventHandler();
  final response = await _makeRequest(body, headers);
  expect(response.statusCode, 400, reason: 'response.statusCode');
  expect(
    response.body,
    'Bad request. Could not decode the request as a $messageType.',
    reason: 'response.body',
  );

  await finishServerTest(
    proc,
    requestOutput: endsWith('POST    [400] /'),
  );

  final stderrOutput = await proc.stderrStream().join('\n');
  return stderrOutput;
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

Future<TestProcess> _hostBasicEventHandler() async {
  final proc = await startServerTest(
    arguments: [
      '--target',
      'basicCloudEventHandler',
      '--signature-type',
      'cloudevent',
    ],
    expectedListeningPort: 0,
  );
  return proc;
}
