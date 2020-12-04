// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:stack_trace/stack_trace.dart';

import 'constants.dart';

/// Return [Middleware] that logs errors using Google Cloud structured logs.
Middleware cloudLoggingMiddleware(String projectid) {
  Handler hostedLoggingMiddleware(Handler innerHandler) => (request) async {
        // Add log correlation to nest all log messages beneath request log in
        // Log Viewer.
        final traceHeader = request.headers[cloudTraceContextHeader];

        String traceValue() =>
            'projects/$projectid/traces/${traceHeader.split('/')[0]}';

        try {
          // TODO: GoogleCloudPlatform/functions-framework-dart#41 look into
          // using zone error handling, too. Need to debug this.
          final response = await Zone.current.fork(
            specification: ZoneSpecification(
              print: (self, parent, zone, line) {
                final logContent = {
                  'message': line,
                  'severity': 'INFO',
                  // 'logging.googleapis.com/labels': { }
                  if (traceHeader != null)
                    'logging.googleapis.com/trace': traceValue(),
                };

                // Serialize to a JSON string and output to parent zone.
                parent.print(self, jsonEncode(logContent));
              },
            ),
          ).runUnary(innerHandler, request);

          return response;
        } catch (error, stackTrace) {
          if (error is HijackException) rethrow;

          // Collect and format error information as described here
          // https://cloud.google.com/functions/docs/monitoring/logging#writing_structured_logs

          final chain = stackTrace == null
              ? Chain.current()
              : Chain.forTrace(stackTrace)
                  .foldFrames((frame) => frame.isCore)
                  .terse;

          final stackFrame = _frameFromChain(chain);

          // https://cloud.google.com/logging/docs/agent/configuration#special-fields
          final logContent = {
            'message': '$error\n$chain',
            'severity': 'ERROR',
            // 'logging.googleapis.com/labels': { }
            if (traceHeader != null)
              'logging.googleapis.com/trace': traceValue(),
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
