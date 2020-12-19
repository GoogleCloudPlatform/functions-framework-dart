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

import 'package:shelf/shelf.dart';

import '../bad_request_exception.dart';
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
    final event = _requiredBinaryHeader.every(request.headers.containsKey)
        ? await _decodeBinary(request)
        : await _decodeStructured(request);

    await function(event);

    return Response.ok('');
  }

  const CloudEventFunctionTarget(String target, this.function) : super(target);
}

class CloudEventWithContextFunctionTarget extends FunctionTarget {
  final CloudEventWithContextHandler function;

  @override
  FunctionType get type => FunctionType.cloudevent;

  @override
  Future<Response> handler(Request request) async {
    final event = _requiredBinaryHeader.every(request.headers.containsKey)
        ? await _decodeBinary(request)
        : await _decodeStructured(request);

    final context = contextForRequest(request);
    await function(event, context);

    return Response.ok('');
  }

  const CloudEventWithContextFunctionTarget(String target, this.function)
      : super(target);
}

Future<CloudEvent> _decodeStructured(Request request) async {
  final type = mediaTypeFromRequest(request);

  mustBeJson(type);
  var jsonObject = await decodeJson(request) as Map<String, dynamic>;

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

  final type = mediaTypeFromRequest(request);

  mustBeJson(type);
  map['datacontenttype'] = type.toString();
  map['data'] = await decodeJson(request);

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
