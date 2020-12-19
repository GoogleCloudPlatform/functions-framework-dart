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

import 'function_config.dart';
import 'targets/cloud_event_targets.dart';
import 'targets/http_targets.dart';
import 'typedefs.dart';

export 'targets/json_targets.dart';

abstract class FunctionTarget {
  final String name;

  FunctionType get type => FunctionType.http;

  const FunctionTarget(this.name);

  const factory FunctionTarget.http(String target, Handler function) =
      HttpFunctionTarget;

  const factory FunctionTarget.httpWithLogger(
    String target,
    HandlerWithLogger function,
  ) = HttpWithLoggerFunctionTarget;

  const factory FunctionTarget.cloudEvent(
    String target,
    CloudEventHandler function,
  ) = CloudEventFunctionTarget;

  const factory FunctionTarget.cloudEventWithContext(
    String target,
    CloudEventWithContextHandler function,
  ) = CloudEventWithContextFunctionTarget;

  FutureOr<Response> handler(Request request);
}
