import 'dart:async';

import 'package:http/http.dart';

FutureOr<void> main() async {
  const requestUrl = 'http://localhost:8080';

  const headers = {
    'content-type': 'application/json',
  };

  const body = r'''
{
  "specversion": "1.0",
  "type": "google.cloud.pubsub.topic.publish",
  "time": "2020-09-05T03:56:24.000Z",
  "id": "1234-1234-1234",
  "source": "urn:uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66",
  "subject": "STRUCTURED_MODE_CLOUDEVENT_SAMPLE",
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

  final response = await post(requestUrl, headers: headers, body: body);
  print('response.statusCode: ${response.statusCode}');
}
