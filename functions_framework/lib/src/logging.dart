// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:stack_trace/stack_trace.dart';

import 'constants.dart';

/// If [projectid] is provided, assume we're running on Google Cloud and return
/// [Middleware] that logs errors using Google Cloud structured logs.
///
/// Otherwise, returns [Middleware] that prints requests and errors to `stdout`.
Middleware loggingMiddleware({String projectid}) {
  if (projectid == null) {
    return logRequests();
  }

  Handler hostedLoggingMiddleware(Handler innerHandler) => (request) async {
        try {
          // including the extra `await` and assignment here to make sure async
          // errors are caught within this try block
          final response = await innerHandler(request);
          return response;
        } catch (error, stackTrace) {
          if (error is HijackException) rethrow;

          // Collect and format error information as described here
          // https://cloud.google.com/functions/docs/monitoring/logging#writing_structured_logs

          final chain = stackTrace == null
              ? Chain.current()
              : Chain.forTrace(stackTrace)
                  .foldFrames(
                      (frame) => frame.isCore || frame.package == 'shelf')
                  .terse;

          final stackFrame = _frameFromChain(chain);

          // Add log correlation to nest all log messages beneath request log in
          // Log Viewer.
          final traceHeader = request.headers[cloudTraceContextHeader];

          // https://cloud.google.com/logging/docs/agent/configuration#special-fields
          final logContent = {
            'message': '$error\n$chain',
            'severity': 'ERROR',
            // 'logging.googleapis.com/labels': { }
            if (traceHeader != null)
              'logging.googleapis.com/trace':
                  'projects/$projectid/traces/${traceHeader.split('/')[0]}',
            if (stackFrame != null)
              'logging.googleapis.com/sourceLocation':
                  _sourceLocation(stackFrame),
          };

          // Serialize to a JSON string and output.
          print(jsonEncode(logContent));

          return Response.internalServerError();
        }
      };

  return hostedLoggingMiddleware;
}

/// Returns a [Frame] from [chain] if possible, otherwise, `null`.
Frame _frameFromChain(Chain chain) {
  if (chain == null || chain.traces.isEmpty) return null;

  final trace = chain.traces.first;
  if (trace.frames.isEmpty) return null;

  return trace.frames.first;
}

// https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#LogEntrySourceLocation
Map<String, dynamic> _sourceLocation(Frame frame) => {
      'file': frame.library,
      if (frame.line != null) 'line': frame.line.toString(),
      'function': frame.member,
    };
