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

import 'dart:convert';
import 'package:meta/meta.dart';

import 'package:stack_trace/stack_trace.dart';

/// See https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#logseverity
enum LogSeverity implements Comparable<LogSeverity> {
  defaultSeverity._(0, 'DEFAULT'),
  debug._(100, 'DEBUG'),
  info._(200, 'INFO'),
  notice._(300, 'NOTICE'),
  warning._(400, 'WARNING'),
  error._(500, 'ERROR'),
  critical._(600, 'CRITICAL'),
  alert._(700, 'ALERT'),
  emergency._(800, 'EMERGENCY');

  final int value;
  final String name;

  const LogSeverity._(this.value, this.name);

  @override
  int compareTo(LogSeverity other) => value.compareTo(other.value);

  bool operator <(LogSeverity other) => value < other.value;

  bool operator <=(LogSeverity other) => value <= other.value;

  bool operator >(LogSeverity other) => value > other.value;

  bool operator >=(LogSeverity other) => value >= other.value;

  @override
  String toString() => 'LogSeverity $name ($value)';

  String toJson() => name;
}

/// Creates a JSON-encoded log entry that conforms with
/// [structured logs](https://cloud.google.com/functions/docs/monitoring/logging#writing_structured_logs).
///
/// [message] is the log message. It SHOULD be JSON-encodable. If it is not, it
/// will be converted to a [String] and used as the log entry message.
String structuredLogEntry(
  Object message,
  LogSeverity severity, {
  String? traceId,
  StackTrace? stackTrace,
}) {
  final stackFrame = _debugFrame(severity, stackTrace: stackTrace);

  // https://cloud.google.com/logging/docs/agent/logging/configuration#special-fields
  Map<String, dynamic> createContent(Object innerMessage) => {
    'message': innerMessage,
    'severity': severity,
    // 'logging.googleapis.com/labels': { }
    'logging.googleapis.com/trace': ?traceId,
    if (stackFrame != null)
      'logging.googleapis.com/sourceLocation': _sourceLocation(stackFrame),
  };

  try {
    return jsonEncode(createContent(message));
  } catch (e) {
    return jsonEncode(createContent(message.toString()));
  }
}

/// Returns a [Map] representing the source location of the given [frame].
///
/// See https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#LogEntrySourceLocation
Map<String, dynamic> _sourceLocation(Frame frame) => {
  // TODO: Will need to fix `package:` URIs to file paths when possible
  // GoogleCloudPlatform/functions-framework-dart#40
  'file': frame.uri.toString(),
  if (frame.line != null) 'line': frame.line.toString(),
  'function': frame.member,
};

Frame? _debugFrame(LogSeverity severity, {StackTrace? stackTrace}) {
  if (stackTrace == null) {
    if (severity >= LogSeverity.warning) {
      stackTrace = StackTrace.current;
    } else {
      return null;
    }
  }

  final chain = formatStackTrace(stackTrace);
  final stackFrame = chain.traces
      .expand((t) => t.frames)
      .firstWhere(
        (f) => !_frameFolder(f),
        orElse: () => chain.traces.first.frames.first,
      );

  return stackFrame;
}

@internal
Chain formatStackTrace(StackTrace? stackTrace) =>
    (stackTrace == null ? Chain.current() : Chain.forTrace(stackTrace))
        .foldFrames(_frameFolder, terse: true);

bool _frameFolder(Frame frame) =>
    frame.isCore || frame.package == 'google_cloud';
