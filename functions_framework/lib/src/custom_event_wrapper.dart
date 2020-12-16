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

typedef CustomEventHandler<RequestType, ResponseType> = FutureOr<ResponseType>
    Function(RequestType request);

class CustomTypeFunctionEndPoint<RequestType, ResponseType>
    extends FunctionEndpoint {
  final CustomEventHandler<RequestType, ResponseType> function;
  final RequestType Function(Object) fromJson;

  @override
  FunctionType get functionType => FunctionType.http;

  @override
  Handler get handler => (request) async {
        final argument = await _argument(request, fromJson);
        final response = await function(argument);
        final responseJson = jsonEncode(response);

        return Response.ok(
          responseJson,
          headers: const {contentTypeHeader: jsonContentType},
        );
      };

  const CustomTypeFunctionEndPoint(
    String target,
    this.function,
    this.fromJson,
  ) : super(target);
}

class VoidCustomTypeFunctionEndPoint<RequestType> extends FunctionEndpoint {
  final CustomEventHandler<RequestType, void> function;
  final RequestType Function(Object) fromJson;

  @override
  FunctionType get functionType => FunctionType.http;

  @override
  Handler get handler => (request) async {
        final argument = await _argument(request, fromJson);
        await function(argument);
        return Response.ok('');
      };

  const VoidCustomTypeFunctionEndPoint(
    String target,
    this.function,
    this.fromJson,
  ) : super(target);
}

Future<T> _argument<T>(Request request, T Function(Object) fromJson) async {
  final type = mediaTypeFromRequest(request);
  mustBeJson(type);
  final jsonObject = await decodeJson(request);
  return fromJson(jsonObject);
}
