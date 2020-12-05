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

import 'dart:async';
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:shelf/shelf.dart';

import 'cloud_event.dart';

typedef CloudEventHandler = FutureOr<void> Function(CloudEvent request);

Handler wrapCloudEventHandler(CloudEventHandler handler) => (request) async {
      final map = Map<String, dynamic>.fromEntries(request.headers.entries
          .where((element) => element.key.startsWith('ce-'))
          .map((e) => MapEntry(e.key.substring(3), e.value)));

      // TODO: if we're missing the needed headers, then...
      // TODO: see if this is a structured message
      // TODO: if not, throw a 4xx

      final type = MediaType.parse(request.headers[_contentTypeHeader]);
      if (type.mimeType == _jsonContentType) {
        map['datacontenttype'] = type.toString();
        map['data'] = jsonDecode(await request.readAsString()) as Object;
      } else {
        // TODO: not sure exactly what to do here...
        throw UnimplementedError();
      }

      final event = CloudEvent.fromJson(map);

      await handler(event);

      return Response.ok('');
    };

const _contentTypeHeader = 'Content-Type';
const _jsonContentType = 'application/json';
