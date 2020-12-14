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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:stack_trace/stack_trace.dart';

import 'bad_request_exception.dart';
import 'constants.dart';
import 'log_severity.dart';

final _loggerKey = Object();

CloudLogger get logger =>
    Zone.current[_loggerKey] as CloudLogger ?? const _DefaultLogger();

Middleware createLoggingMiddleware(String projectId) =>
    projectId == null ? _logSimple : cloudLoggingMiddleware(projectId);

/// Logging middleware that "does the right thing" when not hosted on
/// Google Cloud.
Middleware get _logSimple => const Pipeline()
    .addMiddleware(logRequests())
    .addMiddleware(_handleBadRequest)
    .middleware;

/// Wraps [innerHandler], but catches any errors of type [BadRequestException].
///
/// Error details are written to [stderr] and a corresponding error [Response]
/// is returned.
Handler _handleBadRequest(Handler innerHandler) => (request) async {
      try {
        final response = await innerHandler(request);
        return response;
      } on BadRequestException catch (e) {
        stderr.writeln(e);
        return _fromBadRequestException(e);
      }
    };

Response _fromBadRequestException(BadRequestException e) => Response(
      e.statusCode,
      body: 'Bad request. ${e.message}',
      context: {
        'bad_request_exception': e,
      },
    );

/// Return [Middleware] that logs errors using Google Cloud structured logs and
/// returns the correct response.
Middleware cloudLoggingMiddleware(String projectid) {
  Handler hostedLoggingMiddleware(Handler innerHandler) => (request) async {
        // Add log correlation to nest all log messages beneath request log in
        // Log Viewer.

        String traceValue;

        final traceHeader = request.headers[cloudTraceContextHeader];
        if (traceHeader != null) {
          traceValue =
              'projects/$projectid/traces/${traceHeader.split('/')[0]}';
        }

        String createErrorLogEntry(
          Object error,
          StackTrace stackTrace,
          LogSeverity logSeverity, {
          bool Function(Frame) predicate,
        }) {
          assert(error != null);
          // Collect and format error information as described here
          // https://cloud.google.com/functions/docs/monitoring/logging#writing_structured_logs

          final chain = stackTrace == null
              ? Chain.current()
              : Chain.forTrace(stackTrace).foldFrames(
                  predicate ??
                      (f) =>
                          f.package == 'functions_framework' ||
                          f.package == 'shelf',
                  terse: true,
                );

          final stackFrame = _frameFromChain(chain);

          return _createLogEntry(
            traceValue,
            '$error\n$chain'.trim(),
            logSeverity,
            stackFrame: stackFrame,
          );
        }

        final completer = Completer<Response>.sync();

        Zone.current
            .fork(
          zoneValues: traceValue == null
              ? null
              : {
                  _loggerKey: _CloudLogger(Zone.current, traceValue),
                },
          specification: ZoneSpecification(
            handleUncaughtError: (self, parent, zone, error, stackTrace) {
              if (error is HijackException) {
                completer.completeError(error, stackTrace);
              }

              final logContentString = error is BadRequestException
                  ? createErrorLogEntry(
                      'Bad request. ${error.message}',
                      error.innerStack ?? stackTrace,
                      LogSeverity.warning,
                      // Since the error should have been raised within the
                      // framework, we want to see the stack within
                      // functions_framework
                      predicate: (f) => f.package == 'shelf',
                    )
                  : createErrorLogEntry(
                      error,
                      stackTrace,
                      LogSeverity.error,
                    );

              // Serialize to a JSON string and output.
              parent.print(self, logContentString);

              if (completer.isCompleted) {
                return;
              }

              final response = error is BadRequestException
                  ? _fromBadRequestException(error)
                  : Response.internalServerError();

              completer.complete(response);
            },
            print: (self, parent, zone, line) {
              final logContent = _createLogEntry(
                traceValue,
                line,
                LogSeverity.info,
              );

              // Serialize to a JSON string and output to parent zone.
              parent.print(self, logContent);
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

  // Try to exclude frames in `package:json_annotation`
  // These are likely the checked-yaml logic, which isn't helpful for debugging
  final frame = trace.frames.firstWhere(
      (element) => element.package != 'json_annotation',
      orElse: () => null);

  return frame ?? trace.frames.first;
}

// https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#LogEntrySourceLocation
Map<String, dynamic> _sourceLocation(Frame frame) => {
      // TODO: Will need to fix `package:` URIs to file paths when possible
      // GoogleCloudPlatform/functions-framework-dart#40
      'file': frame.library,
      if (frame.line != null) 'line': frame.line.toString(),
      'function': frame.member,
    };

/// A [CloudLogger] that prints messages normally.
///
/// Any message that's not [LogSeverity.defaultSeverity] is prefixed by the
/// [LogSeverity] name.
class _DefaultLogger extends CloudLogger {
  const _DefaultLogger();

  @override
  void log(Object message, LogSeverity severity) {
    if (severity == LogSeverity.defaultSeverity) {
      print(message);
    } else {
      print('${severity.name}: $message');
    }
  }
}

/// A [CloudLogger] that prints messages using Google Cloud structured logging.
class _CloudLogger extends CloudLogger {
  final Zone _zone;
  final String _traceId;

  _CloudLogger(this._zone, this._traceId);

  @override
  void log(Object message, LogSeverity severity) {
    _zone.print(_createLogEntry(_traceId, '$message', severity));
  }
}

String _createLogEntry(
  String traceValue,
  String message,
  LogSeverity severity, {
  Frame stackFrame,
}) {
  // https://cloud.google.com/logging/docs/agent/configuration#special-fields
  final logContent = {
    'message': message,
    'severity': severity,
    // 'logging.googleapis.com/labels': { }
    if (traceValue != null) 'logging.googleapis.com/trace': traceValue,
    if (stackFrame != null)
      'logging.googleapis.com/sourceLocation': _sourceLocation(stackFrame),
  };
  return jsonEncode(logContent);
}
