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

import 'src/test_utils.dart';

void main() {
  // TODO: non-JSON body
  // TODO: JSON-body, but not a Map
  // TODO: JSON-body is a map, but wrong/missing keys/values
  // TODO: invalid header value encoding (bad date time, for instance)
  // TODO: proper error logging when hosted on cloud

  test('binary-mode message', () async {
    final proc = await startServerTest(
      arguments: [
        '--target',
        'basicCloudEventHandler',
        '--signature-type',
        'cloudevent',
      ],
      expectedListeningPort: 0,
    );

    final requestUrl = 'http://localhost:$autoPort/';

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

    final response = await post(
      requestUrl,
      body: body,
      headers: {
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

  test('structured-mode message', () async {
    final proc = await startServerTest(
      arguments: [
        '--target',
        'basicCloudEventHandler',
        '--signature-type',
        'cloudevent',
      ],
      expectedListeningPort: 0,
    );

    final requestUrl = 'http://localhost:$autoPort/';

    const body = r'''
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
}''';

    final response = await post(
      requestUrl,
      body: body,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
    );
    expect(response.statusCode, 200);
    expect(response.body, isEmpty);

    await finishServerTest(
      proc,
      requestOutput: endsWith('POST    [200] /'),
    );

    final stderrOutput = await proc.stderrStream().join('\n');

    addTearDown(() {
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
