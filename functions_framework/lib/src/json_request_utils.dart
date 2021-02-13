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

import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:shelf/shelf.dart';

import 'bad_request_exception.dart';

MediaType mediaTypeFromRequest(Request request) {
  final contentType = request.headers[contentTypeHeader];
  if (contentType == null) {
    throw BadRequestException(400, '$contentTypeHeader header is required.');
  }
  try {
    return MediaType.parse(contentType);
  } catch (e, stack) {
    throw BadRequestException(
      400,
      'Could not parse $contentTypeHeader header.',
      innerError: e,
      innerStack: stack,
    );
  }
}

void mustBeJson(MediaType type) {
  if (type.mimeType != jsonContentType) {
    // https://github.com/GoogleCloudPlatform/functions-framework#http-status-codes
    throw BadRequestException(
      400,
      'Unsupported encoding "${type.toString()}". '
      'Only "$jsonContentType" is supported.',
    );
  }
}

Future<Object> decodeJson(Request request) async {
  final content = await request.readAsString();
  try {
    final value = jsonDecode(content);
    return value;
  } on FormatException catch (e, stackTrace) {
    // https://github.com/GoogleCloudPlatform/functions-framework#http-status-codes
    throw BadRequestException(
      400,
      'Could not parse the request body as JSON.',
      innerError: e,
      innerStack: stackTrace,
    );
  }
}

const jsonContentType = 'application/json';

const contentTypeHeader = 'Content-Type';
