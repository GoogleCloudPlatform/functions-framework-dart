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

import '../functions_framework.dart';
import 'function_config.dart';
import 'targets/cloud_event_targets.dart';
import 'targets/http_targets.dart';
import 'targets/json_targets.dart';

export 'targets/json_targets.dart';

abstract class FunctionTarget {
  FunctionTarget();

  FunctionType get type => FunctionType.http;

  Future<Response> handler(Request request);

  factory FunctionTarget.cloudEvent(CloudEventHandler function) =
      CloudEventWithContextFunctionTarget;

  factory FunctionTarget.http(Handler function) = HttpFunctionTarget;

  factory FunctionTarget.httpWithLogger(HandlerWithLogger function) =
      HttpWithLoggerFunctionTarget;

  static FunctionTarget jsonable<RequestType, ResponseType>(
    Future<ResponseType> Function(RequestType object, RequestContext context)
        handler,
    RequestType Function(Map<String, dynamic> json) fromJson,
  ) =>
      JsonFunctionTarget.voidResult(handler, (json) {
        if (json is Map<String, dynamic>) {
          try {
            return fromJson(json);
          } catch (e, stack) {
            throw BadRequestException(
              400,
              'There was an error parsing the provided JSON data.',
              innerError: e,
              innerStack: stack,
            );
          }
        }
        throw BadRequestException(
          400,
          'The provided JSON is not the expected type '
          '`Map<String, dynamic>`.',
        );
      });

  static FunctionTarget json(
    Future<void> Function(Map<String, dynamic> json, RequestContext context)
        handler,
  ) =>
      JsonFunctionTarget(handler, (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }
        throw BadRequestException(
          400,
          'The provided JSON is not the expected type '
          '`Map<String, dynamic>`.',
        );
      });
}
