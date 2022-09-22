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

import 'package:stack_trace/stack_trace.dart';

/// When thrown in a request handler, causes a response with a status code
/// [statusCode] to be returned.
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

  String errorMessage(Uri requestedUri, String method, StackTrace stack) {
    final buffer = StringBuffer()
      ..writeln('[BAD REQUEST] $method\t'
          '${requestedUri.path}${_formatQuery(requestedUri.query)}')
      ..writeln(this);

    if (innerError != null) {
      buffer.writeln('$innerError'.trim());
    }

    final chain = Chain.forTrace(innerStack ?? stack)
        .foldFrames(
          (frame) =>
              frame.isCore ||
              frame.package == 'shelf' ||
              frame.package == 'functions_framework',
        )
        .terse;

    buffer.write('$chain'.trim());

    return buffer.toString();
  }
}

String _formatQuery(String query) => query == '' ? '' : '?$query';
