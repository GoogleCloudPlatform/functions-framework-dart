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

import 'cloud_event_wrapper.dart';
import 'function_config.dart';
import 'log_severity.dart';
import 'logging.dart' show loggerForRequest;

typedef HandlerWithLogger = FutureOr<Response> Function(
  Request request,
  CloudLogger logger,
);

abstract class FunctionEndpoint {
  final String target;

  FunctionType get functionType;

  Handler get handler;

  const FunctionEndpoint(this.target);

  const factory FunctionEndpoint.http(String target, Handler function) =
      _HttpFunctionEndPoint;

  const factory FunctionEndpoint.httpWithLogger(
    String target,
    HandlerWithLogger function,
  ) = _HttpFunctionWithLoggerEndPoint;

  const factory FunctionEndpoint.cloudEvent(
    String target,
    CloudEventHandler function,
  ) = _CloudEventFunctionEndPoint;

  const factory FunctionEndpoint.cloudEventWithContext(
    String target,
    CloudEventWithContextHandler function,
  ) = _CloudEventFunctionWithLoggerEndPoint;
}

class _HttpFunctionEndPoint extends FunctionEndpoint {
  final Handler function;

  @override
  FunctionType get functionType => FunctionType.http;

  @override
  Handler get handler => function;

  const _HttpFunctionEndPoint(String target, this.function) : super(target);
}

class _HttpFunctionWithLoggerEndPoint extends FunctionEndpoint {
  final HandlerWithLogger function;

  @override
  FunctionType get functionType => FunctionType.http;

  @override
  Handler get handler =>
      (request) async => await function(request, loggerForRequest(request));

  const _HttpFunctionWithLoggerEndPoint(String target, this.function)
      : super(target);
}

class _CloudEventFunctionEndPoint extends FunctionEndpoint {
  final CloudEventHandler function;

  @override
  FunctionType get functionType => FunctionType.cloudevent;

  @override
  Handler get handler => wrapCloudEventFunction(function);

  const _CloudEventFunctionEndPoint(String target, this.function)
      : super(target);
}

class _CloudEventFunctionWithLoggerEndPoint extends FunctionEndpoint {
  final CloudEventWithContextHandler function;

  @override
  FunctionType get functionType => FunctionType.cloudevent;

  @override
  Handler get handler => wrapCloudEventWithContextFunction(function);

  const _CloudEventFunctionWithLoggerEndPoint(String target, this.function)
      : super(target);
}
