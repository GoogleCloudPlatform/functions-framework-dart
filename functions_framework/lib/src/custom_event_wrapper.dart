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

import 'function_config.dart';
import 'function_endpoint.dart';
import 'json_request_utils.dart';
import 'request_context.dart';

typedef CustomEventHandler<RequestType, ResponseType> = FutureOr<ResponseType>
    Function(RequestType request);

typedef CustomEventWithContextHandler<RequestType, ResponseType>
    = FutureOr<ResponseType> Function(
  RequestType request,
  RequestContext context,
);

abstract class _CustomTypeFunctionEndPoint<RequestType>
    extends FunctionEndpoint {
  final RequestType Function(Object) _fromJson;
  final bool _isVoid;

  @override
  FunctionType get functionType => FunctionType.http;

  @override
  Handler get handler => _isVoid ? _voidHandler : _handler;

  Handler get _handler;

  Handler get _voidHandler;

  const _CustomTypeFunctionEndPoint(
    String target,
    this._fromJson,
    this._isVoid,
  ) : super(target);
}

class CustomTypeFunctionEndPoint<RequestType, ResponseType>
    extends _CustomTypeFunctionEndPoint<RequestType> {
  final CustomEventHandler<RequestType, ResponseType> _function;

  @override
  Handler get _handler => (request) async {
        final argument = await _argument(request, _fromJson);
        final response = await _function(argument);
        final responseJson = jsonEncode(response);

        return Response.ok(
          responseJson,
          headers: const {contentTypeHeader: jsonContentType},
        );
      };

  @override
  Handler get _voidHandler => (request) async {
        final argument = await _argument(request, _fromJson);
        await _function(argument);
        return Response.ok('');
      };

  const CustomTypeFunctionEndPoint(
    String target,
    this._function,
    RequestType Function(Object) fromJson,
  ) : super(target, fromJson, false);

  const CustomTypeFunctionEndPoint.voidResult(
    String target,
    this._function,
    RequestType Function(Object) fromJson,
  ) : super(target, fromJson, true);
}

class CustomTypeWithContextFunctionEndPoint<RequestType, ResponseType>
    extends _CustomTypeFunctionEndPoint<RequestType> {
  final CustomEventWithContextHandler<RequestType, ResponseType> _function;

  @override
  Handler get _handler => (request) async {
        final argument = await _argument(request, _fromJson);
        final context = contextForRequest(request);
        final response = await _function(argument, context);
        final responseJson = jsonEncode(response);

        return Response.ok(
          responseJson,
          headers: const {contentTypeHeader: jsonContentType},
        );
      };

  @override
  Handler get _voidHandler => (request) async {
        final argument = await _argument(request, _fromJson);
        final context = contextForRequest(request);
        await _function(argument, context);
        return Response.ok('');
      };

  const CustomTypeWithContextFunctionEndPoint(
    String target,
    this._function,
    RequestType Function(Object) fromJson,
  ) : super(target, fromJson, false);

  const CustomTypeWithContextFunctionEndPoint.voidResult(
    String target,
    this._function,
    RequestType Function(Object) fromJson,
  ) : super(target, fromJson, true);
}

Future<T> _argument<T>(Request request, T Function(Object) fromJson) async {
  final type = mediaTypeFromRequest(request);
  mustBeJson(type);
  final jsonObject = await decodeJson(request);
  return fromJson(jsonObject);
}
