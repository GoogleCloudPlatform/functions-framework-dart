// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

class BadConfigurationException implements Exception {
  final String message;
  final String details;

  BadConfigurationException(this.message, {this.details});

  @override
  String toString() => 'BadConfiguration: $message';
}
