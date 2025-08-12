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

import 'package:shelf/shelf.dart';

import '../function_target.dart';
import '../json_request_utils.dart';
import '../request_context.dart';
import '../typedefs.dart';

abstract class _JsonFunctionTargetBase<RequestType> extends FunctionTarget {
  final RequestType Function(Object?) _fromJson;

  _JsonFunctionTargetBase(this._fromJson);

  Future<RequestType> _toRequestType(Request request) async {
    mediaTypeFromRequest(request, requiredMimeType: jsonContentType);
    final jsonObject = await request.decodeJson();
    return _fromJson(jsonObject);
  }
}

abstract class JsonFunctionTarget<RequestType, ResponseType>
    extends _JsonFunctionTargetBase<RequestType> {
  final JsonHandler<RequestType, ResponseType> _function;

  JsonFunctionTarget._(
    this._function,
    RequestType Function(Object?) fromJson,
  ) : super(fromJson);

  factory JsonFunctionTarget(
    JsonHandler<RequestType, ResponseType> function,
    RequestType Function(Object?) fromJson,
  ) = _JsonWithContextFunctionTarget<RequestType, ResponseType>;

  factory JsonFunctionTarget.voidResult(
    JsonHandler<RequestType, ResponseType> function,
    RequestType Function(Object?) fromJson,
  ) = _VoidJsonWithContextFunctionTarget<RequestType, ResponseType>;
}

class _JsonWithContextFunctionTarget<RequestType, ResponseType>
    extends JsonFunctionTarget<RequestType, ResponseType> {
  _JsonWithContextFunctionTarget(super.function, super.fromJson) : super._();

  @override
  Future<Response> handler(Request request) async {
    final argument = await _toRequestType(request);
    final context = contextForRequest(request);
    final response = await _function(argument, context);
    final responseJson = jsonEncode(response);

    return Response.ok(
      responseJson,
      headers: context.responseHeaders.isEmpty
          ? const {contentTypeHeader: jsonContentType}
          : {contentTypeHeader: jsonContentType, ...context.responseHeaders},
    );
  }
}

class _VoidJsonWithContextFunctionTarget<RequestType, ResponseType>
    extends JsonFunctionTarget<RequestType, ResponseType> {
  _VoidJsonWithContextFunctionTarget(super.function, super.fromJson)
      : super._();

  @override
  Future<Response> handler(Request request) async {
    final argument = await _toRequestType(request);
    final context = contextForRequest(request);
    await _function(argument, context);
    return Response.ok('', headers: context.responseHeaders);
  }
}
