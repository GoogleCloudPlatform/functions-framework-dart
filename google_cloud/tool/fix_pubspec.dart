#!/usr/bin/env dart

import 'dart:io';

// Removes the `workspace` property from the pubspec so it can be used via
// Docker.
// Work-around for https://github.com/dart-lang/pub/issues/4357
void main(List<String> args) {
  final file = File('pubspec.yaml');
  final content = file.readAsStringSync().replaceAll(_content, '');
  file.writeAsStringSync(content);
}

const _content = r'''resolution: workspace
''';
