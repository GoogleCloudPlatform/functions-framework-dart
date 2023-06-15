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

import 'package:collection/collection.dart';
import 'package:io/ansi.dart';
import 'package:shelf/shelf.dart';
import 'package:stack_trace/stack_trace.dart';

import 'bad_request_exception.dart';
import 'constants.dart';
import 'log_severity.dart';

/// Returns the current [RequestLogger].
///
/// If called within [cloudLoggingMiddleware], the returned [RequestLogger] will
/// create output that conforms with
/// [structured logs](https://cloud.google.com/functions/docs/monitoring/logging#writing_structured_logs).
///
/// Otherwise, the returned [RequestLogger] will simply [print] log entries,
/// with entries having a [LogSeverity] different than
/// [LogSeverity.defaultSeverity] being prefixed as such.
RequestLogger get currentLogger =>
    Zone.current[_loggerKey] as RequestLogger? ?? const _DefaultLogger();

/// Convenience [Middleware] that handles logging depending on [projectId].
///
/// If [projectId] is `null`, returns [Middleware] composed of [logRequests] and
/// [badRequestMiddleware].
///
/// If [projectId] is provided, returns the value from [cloudLoggingMiddleware].
Middleware createLoggingMiddleware({String? projectId}) => projectId == null
    ? _errorWriter.addMiddleware(logRequests()).addMiddleware(_handleBadRequest)
    : cloudLoggingMiddleware(projectId);

/// Adds logic which catches [BadRequestException], logs details to [stderr] and
/// returns a corresponding [Response].
Middleware get badRequestMiddleware => _handleBadRequest;

Handler _handleBadRequest(Handler innerHandler) => (request) async {
      try {
        final response = await innerHandler(request);
        return response;
      } on BadRequestException catch (error, stack) {
        return _responseFromBadRequest(error, stack);
      }
    };

Handler _errorWriter(Handler innerHandler) => (request) async {
      final response = await innerHandler(request);

      final error =
          response.context['bad_request_exception'] as BadRequestException?;

      if (error != null) {
        final stack = response.context['bad_stack_trace'] as StackTrace?;
        final output = [
          error,
          if (error.innerError != null)
            '${error.innerError} (${error.innerError.runtimeType})',
          _fromStackTrace(error.innerStack ?? stack)
        ];

        final bob =
            output.expand((e) => LineSplitter.split('$e'.trim())).join('\n');

        stderr.writeln(lightRed.wrap(bob));
      }
      return response;
    };

Response _responseFromBadRequest(BadRequestException e, StackTrace stack) =>
    Response(
      e.statusCode,
      body: 'Bad request. ${e.message}',
      context: {
        'bad_request_exception': e,
        'bad_stack_trace': stack,
      },
    );

/// Used to represent the [RequestLogger] in [Zone] values.
final _loggerKey = Object();

/// Return [Middleware] that logs errors using Google Cloud structured logs and
/// returns the correct response.
Middleware cloudLoggingMiddleware(String projectId) {
  Handler hostedLoggingMiddleware(Handler innerHandler) => (request) async {
        // Add log correlation to nest all log messages beneath request log in
        // Log Viewer.

        String? traceValue;

        final traceHeader = request.headers[cloudTraceContextHeader];
        if (traceHeader != null) {
          traceValue =
              'projects/$projectId/traces/${traceHeader.split('/')[0]}';
        }

        String createErrorLogEntry(
          Object error,
          StackTrace? stackTrace,
          LogSeverity logSeverity,
        ) {
          // Collect and format error information as described here
          // https://cloud.google.com/functions/docs/monitoring/logging#writing_structured_logs

          final chain = _fromStackTrace(stackTrace);

          final stackFrame = chain.traces.firstOrNull?.frames.firstOrNull;

          return _createLogEntry(
            traceValue,
            '$error\n$chain'.trim(),
            logSeverity,
            stackFrame: stackFrame,
          );
        }

        final completer = Completer<Response>.sync();

        final currentZone = Zone.current;

        Zone.current.fork(
          zoneValues: {_loggerKey: _CloudLogger(currentZone, traceValue)},
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
                  ? _responseFromBadRequest(error, stackTrace)
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
        ).runGuarded(
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

// https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#LogEntrySourceLocation
Map<String, dynamic> _sourceLocation(Frame frame) => {
      // TODO: Will need to fix `package:` URIs to file paths when possible
      // GoogleCloudPlatform/functions-framework-dart#40
      'file': frame.library,
      if (frame.line != null) 'line': frame.line.toString(),
      'function': frame.member,
    };

/// A [RequestLogger] that prints messages normally.
///
/// Any message that's not [LogSeverity.defaultSeverity] is prefixed by the
/// [LogSeverity] name.
class _DefaultLogger extends RequestLogger {
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

/// A [RequestLogger] that prints messages using Google Cloud structured
/// logging.
class _CloudLogger extends RequestLogger {
  final Zone _zone;
  final String? _traceId;

  _CloudLogger(this._zone, this._traceId);

  @override
  void log(Object message, LogSeverity severity) => _zone.print(
        _createLogEntry(
          _traceId,
          message is Map ? message : '$message',
          severity,
        ),
      );
}

String _createLogEntry(
  String? traceValue,
  Object message,
  LogSeverity severity, {
  Frame? stackFrame,
}) {
  // https://cloud.google.com/logging/docs/agent/logging/configuration#special-fields
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

Chain _fromStackTrace(
  StackTrace? stackTrace,
) =>
    (stackTrace == null ? Chain.current() : Chain.forTrace(stackTrace))
        .foldFrames(
      (f) => f.isCore || f.package == 'gcp' || f.package == 'shelf',
      terse: true,
    );
