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

import 'package:gcp/gcp.dart';
import 'package:shelf/shelf.dart';

import 'cloud_event.dart';
import 'request_context.dart';

/// The shape of a handler for [CloudEvent] types.
typedef CloudEventHandler = FutureOr<void> Function(CloudEvent request);

/// The shape of a handler for [CloudEvent] types while also providing a
/// [RequestContext].
typedef CloudEventWithContextHandler = FutureOr<void> Function(
  CloudEvent request,
  RequestContext context,
);

/// The shape of a handler that supports a custom [RequestType] and
/// [ResponseType].
///
/// The [RequestType] must be either a type compatible with a JSON literal or
/// have a `fromJson` constructor with a single, positional parameter that is
/// compatible with a JSON literal.
///
/// The [ResponseType] must be either a type compatible with a JSON literal or
/// have a `toJson()` function with a returns type compatible with a JSON
/// literal.
typedef JsonHandler<RequestType, ResponseType> = FutureOr<ResponseType>
    Function(RequestType request);

/// The shape of a handler that supports a custom [RequestType] and
/// [ResponseType] and while also providing a [RequestContext].
///
/// See [JsonHandler] for the type requirements for [RequestType] and
/// [ResponseType].
typedef JsonWithContextHandler<RequestType, ResponseType>
    = FutureOr<ResponseType> Function(
  RequestType request,
  RequestContext context,
);

/// The shape of a basic handler that follows the
/// [package:shelf](https://pub.dev/packages/shelf) [Handler] pattern while also
/// providing a [RequestLogger].
typedef HandlerWithLogger = FutureOr<Response> Function(
  Request request,
  RequestLogger logger,
);
