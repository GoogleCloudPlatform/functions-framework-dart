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
import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:shelf/shelf.dart';
import 'package:stack_trace/stack_trace.dart';

import 'cloud_event.dart';

typedef CloudEventHandler = FutureOr<void> Function(CloudEvent request);

Handler wrapCloudEventFunction(CloudEventHandler handler) => (request) async {
      CloudEvent event;

      try {
        event = _requiredBinaryHeader.every(request.headers.containsKey)
            ? await _decodeBinary(request)
            : await _decodeStuctured(request);
      } on _BadRequestException catch (e, stack) {
        // TODO: use this in middleware to properly log exception
        stderr.writeln(e);
        stderr.writeln(Chain.forTrace(stack));
        return Response(
          e.statusCode,
          body: e.message,
          // TODO: use this in middleware to properly log exception
          context: {
            'bad_request_exception': e,
            'bad_request_exception_stack': stack,
          },
        );
      }
      // TODO: Sholud we catch other errors here, too? Hrm...
      await handler(event);

      return Response.ok('');
    };

Future<CloudEvent> _decodeStuctured(Request request) async {
  final type = _mediaTypeFromRequest(request);

  _mustBeJson(type);
  var jsonObject = await _decodeJson(request) as Map<String, dynamic>;

  if (!jsonObject.containsKey('datacontenttype')) {
    jsonObject = {
      ...jsonObject,
      'datacontenttype': type.toString(),
    };
  }

  return CloudEvent.fromJson(jsonObject);
}

Future<CloudEvent> _decodeBinary(Request request) async {
  final map = Map<String, dynamic>.fromEntries(request.headers.entries
      .where((element) => element.key.startsWith('ce-'))
      .map((e) => MapEntry(e.key.substring(3), e.value)));

  final type = _mediaTypeFromRequest(request);

  _mustBeJson(type);
  map['datacontenttype'] = type.toString();
  map['data'] = await _decodeJson(request);

  return CloudEvent.fromJson(map);
}

void _mustBeJson(MediaType type) {
  if (type.mimeType != _jsonContentType) {
    // https://github.com/GoogleCloudPlatform/functions-framework#http-status-codes
    throw _BadRequestException(
      400,
      'Unsupported encoding "${type.toString()}". '
      'Only "$_jsonContentType" is supported.',
    );
  }
}

Future<Object> _decodeJson(Request request) async {
  try {
    final content = await request.readAsString();
    final value = jsonDecode(content);
    return value;
  } on FormatException catch (e, stackTrace) {
    // https://github.com/GoogleCloudPlatform/functions-framework#http-status-codes
    throw _BadRequestException(
      400,
      'Could not parse the request body as JSON.',
      innerError: e,
      innerStack: stackTrace,
    );
  }
}

MediaType _mediaTypeFromRequest(Request request) =>
    MediaType.parse(request.headers[_contentTypeHeader]);

const _requiredBinaryHeader = {
  'ce-type',
  'ce-specversion',
  'ce-source',
  'ce-id',
};

const _contentTypeHeader = 'Content-Type';
const _jsonContentType = 'application/json';

class _BadRequestException implements Exception {
  final int statusCode;
  final String message;
  final Object innerError;
  final StackTrace innerStack;

  _BadRequestException(
    this.statusCode,
    this.message, {
    this.innerError,
    this.innerStack,
  }) {
    if (statusCode < 400 || statusCode > 499) {
      throw ArgumentError.value(
        statusCode,
        'statusCode',
        'Must be between 400 and 499',
      );
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('$message ($statusCode)');
    if (innerError != null) {
      buffer.write('\n$innerError');
    }
    if (innerStack != null) {
      buffer.write('\n${Chain.forTrace(innerStack)}');
    }
    return buffer.toString();
  }
}
