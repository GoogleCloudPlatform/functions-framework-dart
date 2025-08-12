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

/// Provides the features needed to *define* Cloud Functions.
///
/// ```dart
/// // lib/functions.dart
/// import 'package:shelf/shelf.dart';
///
/// Future<Response> function(Request request) async
///   => Response.ok('Hello, World!');
/// ```
library;

export 'package:google_cloud/google_cloud.dart'
    show BadRequestException, LogSeverity, RequestLogger;

export 'src/cloud_event.dart' show CloudEvent;
export 'src/request_context.dart' show RequestContext;
export 'src/typedefs.dart'
    show CloudEventHandler, HandlerWithLogger, JsonWithContextHandler;
