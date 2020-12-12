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

/// See https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#logseverity
class LogSeverity implements Comparable<LogSeverity> {
  static const debug = LogSeverity._(100, 'DEBUG');
  static const info = LogSeverity._(200, 'INFO');
  static const warning = LogSeverity._(400, 'WARNING');
  static const error = LogSeverity._(500, 'ERROR');

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
