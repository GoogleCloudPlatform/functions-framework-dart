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

        final completer = Completer<Response>.sync();

        Zone.current
            .fork(
          specification: ZoneSpecification(
            handleUncaughtError: (self, parent, zone, error, stackTrace) {
              if (error is HijackException) {
                completer.completeError(error, stackTrace);
              }

              // Collect and format error information as described here
              // https://cloud.google.com/functions/docs/monitoring/logging#writing_structured_logs

              final chain = stackTrace == null
                  ? Chain.current()
                  : Chain.forTrace(stackTrace).foldFrames(
                      (f) =>
                          f.package == 'functions_framework' ||
                          f.package == 'shelf',
                      terse: true,
                    );

              final stackFrame = _frameFromChain(chain);

              // https://cloud.google.com/logging/docs/agent/configuration#special-fields
              final logContent = {
                'message': '$error\n$chain'.trim(),
                'severity': 'ERROR',
                // 'logging.googleapis.com/labels': { }
                if (traceHeader != null)
                  'logging.googleapis.com/trace': traceValue(),
                if (stackFrame != null)
                  'logging.googleapis.com/sourceLocation':
                      _sourceLocation(stackFrame),
              };

              // Serialize to a JSON string and output.
              parent.print(self, jsonEncode(logContent));

              if (!completer.isCompleted) {
                completer.complete(Response.internalServerError());
              }
            },
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
        )
            .runGuarded(
          () async {
            final response = await innerHandler(request);
            if (!completer.isCompleted) {
              completer.complete(response);
            }
          },
        );

        return completer.future;
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
      // TODO: Will need to fix `package:` URIs to file paths when possible
      // GoogleCloudPlatform/functions-framework-dart#40
      'file': frame.library,
      if (frame.line != null) 'line': frame.line.toString(),
      'function': frame.member,
    };
