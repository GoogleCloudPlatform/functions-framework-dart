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

import 'package:io/ansi.dart';
import 'package:shelf/shelf.dart';

import '../constants.dart';
import '../logging.dart';
import 'bad_request_exception.dart';

export '../logging.dart';

/// Convenience [Middleware] that handles logging depending on [projectId].
///
/// [projectId] is the optional Google Cloud Project ID used for trace
/// correlation.
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
      formatStackTrace(error.innerStack ?? stack),
    ];

    final bob = output
        .expand((e) => LineSplitter.split('$e'.trim()))
        .join('\n');

    stderr.writeln(lightRed.wrap(bob));
  }
  return response;
};

Response _responseFromBadRequest(BadRequestException e, StackTrace stack) =>
    Response(
      e.statusCode,
      body: 'Bad request. ${e.message}',
      context: {'bad_request_exception': e, 'bad_stack_trace': stack},
    );

/// Return [Middleware] that logs errors using Google Cloud structured logs and
/// returns the correct response.
///
/// [projectId] is the Google Cloud Project ID used for trace correlation.
///
/// Log messages of type [Map] are logged as structured logs (`jsonPayload`);
/// all other logs messages are logged as text logs (`textPayload`).
Middleware cloudLoggingMiddleware(String projectId) {
  Handler hostedLoggingMiddleware(Handler innerHandler) => (request) async {
    // Add log correlation to nest all log messages beneath request log in
    // Log Viewer.

    String? traceValue;

    final traceHeader = request.headers[cloudTraceContextHeader];
    if (traceHeader != null) {
      traceValue = 'projects/$projectId/traces/${traceHeader.split('/')[0]}';
    }

    String createErrorLogEntryFromRequest(
      Object error,
      StackTrace? stackTrace,
      LogSeverity logSeverity,
    ) => structuredLogEntry(
      '$error'.trim(),
      logSeverity,
      traceId: traceValue,
      stackTrace: stackTrace,
    );

    final completer = Completer<Response>.sync();

    final currentZone = Zone.current;

    Zone.current
        .fork(
          zoneValues: {
            _loggerKey: _CloudLogger(zone: currentZone, traceId: traceValue),
          },
          specification: ZoneSpecification(
            handleUncaughtError: (self, parent, zone, error, stackTrace) {
              if (error is HijackException) {
                completer.completeError(error, stackTrace);
              }

              final logContentString = error is BadRequestException
                  ? createErrorLogEntryFromRequest(
                      'Bad request. ${error.message}',
                      error.innerStack ?? stackTrace,
                      LogSeverity.warning,
                    )
                  : createErrorLogEntryFromRequest(
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
              final logContent = structuredLogEntry(
                line,
                LogSeverity.info,
                traceId: traceValue,
              );

              // Serialize to a JSON string and output to parent zone.
              parent.print(self, logContent);
            },
          ),
        )
        .runGuarded(() async {
          final response = await innerHandler(request);
          if (!completer.isCompleted) {
            completer.complete(response);
          }
        });

    return completer.future;
  };

  return hostedLoggingMiddleware;
}

/// Returns the current [RequestLogger].
///
/// If called within a context configured with a [RequestLogger], the returned
/// [RequestLogger] will be used.
///
/// Otherwise, the returned [RequestLogger] will simply [print] log entries,
/// with entries having a [LogSeverity] different than
/// [LogSeverity.defaultSeverity] being prefixed as such.
RequestLogger get currentLogger =>
    Zone.current[_loggerKey] as RequestLogger? ?? const _DefaultLogger();

/// Used to represent the [RequestLogger] in [Zone] values.
final _loggerKey = Object();

/// Allows logging at a specified severity.
///
/// Compatible with the
/// [log severities](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#logseverity)
/// supported by Google Cloud.
abstract final class RequestLogger {
  /// Const constructor for subclasses.
  const RequestLogger();

  /// Logs [message] at the given [severity].
  void log(Object message, LogSeverity severity);

  /// Logs [message] at [LogSeverity.debug] severity.
  void debug(Object message) => log(message, LogSeverity.debug);

  /// Logs [message] at [LogSeverity.info] severity.
  void info(Object message) => log(message, LogSeverity.info);

  /// Logs [message] at [LogSeverity.notice] severity.
  void notice(Object message) => log(message, LogSeverity.notice);

  /// Logs [message] at [LogSeverity.warning] severity.
  void warning(Object message) => log(message, LogSeverity.warning);

  /// Logs [message] at [LogSeverity.error] severity.
  void error(Object message) => log(message, LogSeverity.error);

  /// Logs [message] at [LogSeverity.critical] severity.
  void critical(Object message) => log(message, LogSeverity.critical);

  /// Logs [message] at [LogSeverity.alert] severity.
  void alert(Object message) => log(message, LogSeverity.alert);

  /// Logs [message] at [LogSeverity.emergency] severity.
  void emergency(Object message) => log(message, LogSeverity.emergency);
}

/// A [RequestLogger] that prints messages normally.
///
/// Any message that's not [LogSeverity.defaultSeverity] is prefixed by the
/// [LogSeverity] name.
final class _DefaultLogger extends RequestLogger {
  /// Const constructor.
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
final class _CloudLogger extends RequestLogger {
  final Zone _zone;
  final String? _traceId;

  /// Creates a new [_CloudLogger] that prints structured logs to [_zone].
  ///
  /// If [_traceId] is provided, it is included in the log entry.
  _CloudLogger({Zone? zone, String? traceId})
    : _zone = zone ?? Zone.current,
      _traceId = traceId;

  /// If [message] is a [Map], it is used as the log entry payload. Otherwise,
  /// it is converted to a [String] and used as the log entry message.
  @override
  void log(Object message, LogSeverity severity) => _zone.print(
    structuredLogEntry(
      message is Map ? message : '$message',
      severity,
      traceId: _traceId,
    ),
  );
}
