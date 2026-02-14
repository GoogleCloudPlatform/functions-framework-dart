// Copyright 2022 Google LLC
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

/// Features for serving HTTP requests on Google Cloud Platform.
///
/// This library provides functions to run a `shelf` server that handles
/// requests in a way that is compatible with Google Cloud environments like
/// Cloud Run and Cloud Functions. It includes middleware for logging requests
/// in the format expected by Google Cloud Logging.
///
/// ## Example
///
/// ```dart
/// import 'package:google_cloud/google_cloud.dart';
/// import 'package:shelf/shelf.dart';
///
/// Future<void> main() async {
///   final handler = const Pipeline()
///       .addMiddleware(createLoggingMiddleware())
///       .addHandler(_helloWorldHandler);
///
///   await serveHandler(handler);
/// }
///
/// Response _helloWorldHandler(Request request) {
///   return Response.ok('Hello, World!');
/// }
/// ```
///
/// {@canonicalFor bad_configuration_exception.BadConfigurationException}
/// {@canonicalFor bad_request_exception.BadRequestException}
/// {@canonicalFor http_logging.RequestLogger}
/// {@canonicalFor http_logging.badRequestMiddleware}
/// {@canonicalFor http_logging.cloudLoggingMiddleware}
/// {@canonicalFor http_logging.createLoggingMiddleware}
/// {@canonicalFor http_logging.currentLogger}
/// {@canonicalFor serve.listenPortFromEnvironment}
/// {@canonicalFor serve.serveHandler}
/// {@canonicalFor terminate.waitForTerminate}
library;

export 'src/serving/bad_configuration_exception.dart'
    show BadConfigurationException;
export 'src/serving/bad_request_exception.dart' show BadRequestException;
export 'src/serving/http_logging.dart'
    show
        LogSeverity,
        RequestLogger,
        badRequestMiddleware,
        cloudLoggingMiddleware,
        createLoggingMiddleware,
        currentLogger;
export 'src/serving/serve.dart' show listenPortFromEnvironment, serveHandler;
export 'src/serving/terminate.dart' show waitForTerminate;
