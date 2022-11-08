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

import 'package:shelf/shelf.dart';

import 'logging.dart';

/// When thrown in a [Handler], configured with [badRequestMiddleware] or
/// similar, causes a response with [statusCode] to be returned.
///
/// [statusCode] must be >= `400` and <= `499`.
///
/// [message] is used as the body of the response send to the requester.
///
/// If provided, [innerError] and [innerStack] can be used to provide additional
/// debugging information which is included in logs, but not sent to the
/// requester.
class BadRequestException implements Exception {
  final int statusCode;
  final String message;
  final Object? innerError;
  final StackTrace? innerStack;

  BadRequestException(
    this.statusCode,
    this.message, {
    this.innerError,
    this.innerStack,
  }) : assert(message.isNotEmpty) {
    if (statusCode < 400 || statusCode > 499) {
      throw ArgumentError.value(
        statusCode,
        'statusCode',
        'Must be between 400 and 499',
      );
    }
  }

  @override
  String toString() => '$message ($statusCode)';
}
