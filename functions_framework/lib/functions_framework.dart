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
/// import 'package:functions_framework/functions_framework.dart';
/// import 'package:shelf/shelf.dart';
///
/// @CloudFunction()
/// Response function(Request request) => Response.ok('Hello, World!');
// ```
library functions_framework;

export 'src/bad_request_exception.dart' show BadRequestException;
export 'src/cloud_event.dart' show CloudEvent;
export 'src/cloud_function.dart' show CloudFunction;
export 'src/log_severity.dart' show RequestLogger, LogSeverity;
export 'src/request_context.dart' show RequestContext;
export 'src/typedefs.dart'
    show
        HandlerWithLogger,
        CloudEventHandler,
        CloudEventWithContextHandler,
        JsonHandler,
        JsonWithContextHandler;
