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
class LogSeverity implements Comparable<LogSeverity> {
  static const defaultSeverity = LogSeverity._(0, 'DEFAULT');
  static const debug = LogSeverity._(100, 'DEBUG');
  static const info = LogSeverity._(200, 'INFO');
  static const notice = LogSeverity._(300, 'NOTICE');
  static const warning = LogSeverity._(400, 'WARNING');
  static const error = LogSeverity._(500, 'ERROR');
  static const critical = LogSeverity._(600, 'CRITICAL');
  static const alert = LogSeverity._(700, 'ALERT');
  static const emergency = LogSeverity._(800, 'EMERGENCY');

  final int value;
  final String name;

  const LogSeverity._(this.value, this.name);

  @override
  int compareTo(LogSeverity other) => value.compareTo(other.value);

  @override
  String toString() => 'LogSeverity $name ($value)';

  @override
  bool operator ==(Object other) =>
      other is LogSeverity && other.value == value;

  @override
  int get hashCode => value;

  String toJson() => name;
}
