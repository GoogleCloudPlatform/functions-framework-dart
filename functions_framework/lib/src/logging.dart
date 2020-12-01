// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:shelf/shelf.dart';

/// If hosted on Cloud Run, returns logging middleware that does not print on
/// every request.
///
/// Otherwise, returns logging middleware that prints every request.
Middleware loggingMiddleware() =>
    logRequests(logger: _isHosted ? _hostedLogger : null);

/// `true` if hosted via Cloud Run.
///
/// See https://cloud.google.com/run/docs/reference/container-contract#env-vars
bool get _isHosted => Platform.environment.containsKey('K_SERVICE');

/// Prints [message] if [isError] is `true`
void _hostedLogger(String message, bool isError) {
  if (isError) {
    print(message);
  }
}
