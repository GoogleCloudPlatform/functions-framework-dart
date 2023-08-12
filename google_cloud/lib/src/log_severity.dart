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

/// Allows logging at a specified severity.
///
/// Compatible with the
/// [log severities](https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#logseverity)
/// support by Google Cloud.
abstract class RequestLogger {
  const RequestLogger();

  void log(Object message, LogSeverity severity);

  void debug(Object message) => log(message, LogSeverity.debug);

  void info(Object message) => log(message, LogSeverity.info);

  void notice(Object message) => log(message, LogSeverity.notice);

  void warning(Object message) => log(message, LogSeverity.warning);

  void error(Object message) => log(message, LogSeverity.error);

  void critical(Object message) => log(message, LogSeverity.critical);

  void alert(Object message) => log(message, LogSeverity.alert);

  void emergency(Object message) => log(message, LogSeverity.emergency);
}

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

  @override
  String toString() => 'LogSeverity $name ($value)';

  String toJson() => name;
}
