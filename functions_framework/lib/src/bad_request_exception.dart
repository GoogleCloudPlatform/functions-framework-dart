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

class BadRequestException implements Exception {
  final int statusCode;
  final String message;
  final Object innerError;
  final StackTrace innerStack;

  BadRequestException(
    this.statusCode,
    this.message, {
    this.innerError,
    this.innerStack,
  }) : assert(message != null && message.isNotEmpty) {
    if (statusCode < 400 || statusCode > 499) {
      throw ArgumentError.value(
        statusCode,
        'statusCode',
        'Must be between 400 and 499',
      );
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('$message ($statusCode)');
    if (innerError != null) {
      buffer.write('\n$innerError');
    }
    if (innerStack != null) {
      buffer.write('\n${Chain.forTrace(innerStack)}');
    }
    return buffer.toString();
  }
}
