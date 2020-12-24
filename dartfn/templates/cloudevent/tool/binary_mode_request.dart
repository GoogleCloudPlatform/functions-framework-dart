import 'dart:async';

import 'package:http/http.dart';

FutureOr<void> main() async {
  const requestUrl = 'http://localhost:8080';

  const headers = {
    'content-type': 'application/json',
    'ce-specversion': '1.0',
    'ce-type': 'google.cloud.pubsub.topic.publish',
    'ce-time': '2020-09-05T03:56:24Z',
    'ce-id': '1234-1234-1234',
    'ce-source': 'urn:uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66',
    'ce-subject': 'BINARY_MODE_CLOUDEVENT_SAMPLE',
  };

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

  final response = await post(requestUrl, headers: headers, body: body);
  print('response.statusCode: ${response.statusCode}');
}
