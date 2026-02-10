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

import 'package:google_cloud/google_cloud.dart';
import 'package:shelf/shelf.dart';

import '../cloud_event.dart';
import '../function_config.dart';
import '../function_target.dart';
import '../json_request_utils.dart';
import '../request_context.dart';
import '../typedefs.dart';

class CloudEventFunctionTarget extends FunctionTarget {
  final CloudEventHandler function;

  @override
  FunctionType get type => FunctionType.cloudevent;

  @override
  FutureOr<Response> handler(Request request) async {
    final event = await _eventFromRequest(request);

    await function(event);

    return Response.ok('');
  }

  CloudEventFunctionTarget(this.function);
}

class CloudEventWithContextFunctionTarget extends FunctionTarget {
  final CloudEventWithContextHandler function;

  @override
  FunctionType get type => FunctionType.cloudevent;

  @override
  Future<Response> handler(Request request) async {
    final event = await _eventFromRequest(request);

    final context = contextForRequest(request);
    await function(event, context);

    return Response.ok('', headers: context.responseHeaders);
  }

  CloudEventWithContextFunctionTarget(this.function);
}

Future<CloudEvent> _eventFromRequest(Request request) =>
    _requiredBinaryHeader.every(request.headers.containsKey)
        ? _decodeBinary(request)
        : _decodeStructured(request);

Future<CloudEvent> _decodeStructured(Request request) async {
  final type = mediaTypeFromRequest(request, requiredMimeType: jsonContentType);
  var jsonObject = await request.decodeJson() as Map<String, dynamic>;

  if (!jsonObject.containsKey('datacontenttype')) {
    jsonObject = {...jsonObject, 'datacontenttype': type.toString()};
  }

  return _decodeValidCloudEvent(jsonObject, 'structured-mode message');
}

const _cloudEventPrefix = 'ce-';
const _clientEventPrefixLength = _cloudEventPrefix.length;

Future<CloudEvent> _decodeBinary(Request request) async {
  final data = await request.decode();

  final map = <String, Object?>{
    for (var e in request.headers.entries.where(
      (element) => element.key.startsWith(_cloudEventPrefix),
    ))
      e.key.substring(_clientEventPrefixLength): e.value,
    'datacontenttype': data.mimeType.toString(),
    'data': data.data,
  };

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

const _requiredBinaryHeader = {
  'ce-type',
  'ce-specversion',
  'ce-source',
  'ce-id',
};
