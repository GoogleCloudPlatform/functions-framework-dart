#!/usr/bin/env dart

import 'dart:io';

void main(List<String> args) {
  final file = File('pubspec.yaml');
  final content = file.readAsStringSync().replaceAll(_content, '');
  file.writeAsStringSync(content);
}

const _content = r'''resolution: workspace
''';
