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

import 'bad_request_exception.dart';
import 'cloud_event.dart';

typedef CloudEventHandler = FutureOr<void> Function(CloudEvent request);

Handler wrapCloudEventFunction(CloudEventHandler handler) => (request) async {
      final event = _requiredBinaryHeader.every(request.headers.containsKey)
          ? await _decodeBinary(request)
          : await _decodeStructured(request);

      await handler(event);

      return Response.ok('');
    };

Future<CloudEvent> _decodeStructured(Request request) async {
  final type = _mediaTypeFromRequest(request);

  _mustBeJson(type);
  var jsonObject = await _decodeJson(request) as Map<String, dynamic>;

  if (!jsonObject.containsKey('datacontenttype')) {
    jsonObject = {
      ...jsonObject,
      'datacontenttype': type.toString(),
    };
  }

  return _decodeValidCloudEvent(jsonObject, 'structured-mode message');
}

Future<CloudEvent> _decodeBinary(Request request) async {
  final map = Map<String, dynamic>.fromEntries(request.headers.entries
      .where((element) => element.key.startsWith('ce-'))
      .map((e) => MapEntry(e.key.substring(3), e.value)));

  final type = _mediaTypeFromRequest(request);

  _mustBeJson(type);
  map['datacontenttype'] = type.toString();
  map['data'] = await _decodeJson(request);

  return _decodeValidCloudEvent(map, 'binary-mode message');
}

CloudEvent _decodeValidCloudEvent(
  Map<String, dynamic> map,
  String messageType,
) {
  try {
    return CloudEvent.fromJson(map);
  } catch (e, stackTrace) {
    throw BadRequestException(
      400,
      'Could not decode the request as a $messageType.',
      innerError: e,
      innerStack: stackTrace,
    );
  }
}

void _mustBeJson(MediaType type) {
  if (type.mimeType != _jsonContentType) {
    // https://github.com/GoogleCloudPlatform/functions-framework#http-status-codes
    throw BadRequestException(
      400,
      'Unsupported encoding "${type.toString()}". '
      'Only "$_jsonContentType" is supported.',
    );
  }
}

Future<Object> _decodeJson(Request request) async {
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

MediaType _mediaTypeFromRequest(Request request) {
  final contentType = request.headers[_contentTypeHeader];
  if (contentType == null) {
    throw BadRequestException(400, '$_contentTypeHeader header is required.');
  }
  try {
    return MediaType.parse(request.headers[_contentTypeHeader]);
  } catch (e, stack) {
    throw BadRequestException(
      400,
      'Could not parse $_contentTypeHeader header.',
      innerError: e,
      innerStack: stack,
    );
  }
}

const _requiredBinaryHeader = {
  'ce-type',
  'ce-specversion',
  'ce-source',
  'ce-id',
};

const _contentTypeHeader = 'Content-Type';
const _jsonContentType = 'application/json';
