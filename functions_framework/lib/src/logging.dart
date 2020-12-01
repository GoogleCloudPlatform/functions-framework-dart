// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:stack_trace/stack_trace.dart';

/// If hosted on Cloud Run, returns logging middleware that does not print on
/// every request.
///
/// Otherwise, returns logging middleware that prints every request.
Middleware loggingMiddleware() {
  if (_isHosted) {
    return _hostedLoggingMiddleware;
  }
  return logRequests();
}

Handler _hostedLoggingMiddleware(Handler innerHandler) => (request) async {
      try {
        // including the extra `await` and assignment here to make sure async
        // errors are caught within this try block
        final response = await innerHandler(request);
        return response;
      } catch (error, stackTrace) {
        if (error is HijackException) rethrow;

        // https://cloud.google.com/functions/docs/monitoring/logging#writing_structured_logs

        /*
        // Uncomment and populate this variable in your code:
// $project = 'The project ID of your Cloud Run service';

// Build structured log messages as an object.
const globalLogFields = {};

// Add log correlation to nest all log messages beneath request log in Log Viewer.
const traceHeader = req.header('X-Cloud-Trace-Context');
if (traceHeader && project) {
  const [trace] = traceHeader.split('/');
  globalLogFields[
    'logging.googleapis.com/trace'
  ] = `projects/${project}/traces/${trace}`;
}

// Complete a structured log entry.
const entry = Object.assign(
  {
    severity: 'NOTICE',
    message: 'This is the default display field.',
    // Log viewer accesses 'component' as 'jsonPayload.component'.
    component: 'arbitrary-property',
  },
  globalLogFields
);

// Serialize to a JSON string and output.
console.log(JSON.stringify(entry));
         */

        var chain = Chain.current();
        if (stackTrace != null) {
          chain = Chain.forTrace(stackTrace)
              .foldFrames((frame) => frame.isCore || frame.package == 'shelf')
              .terse;
        }

        print(chain);

        rethrow;
      }
    };

/// `true` if hosted via Cloud Run.
///
/// See https://cloud.google.com/run/docs/reference/container-contract#env-vars
bool get _isHosted => Platform.environment.containsKey('K_SERVICE');
