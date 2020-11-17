@function
library app;

import 'dart:io';
import 'package:functions_framework_dart/functions_framework.dart';

Future<void> handleGet(HttpRequest request) async {
  final response = request.response
    ..statusCode = HttpStatus.ok
    ..writeln('Hello, World!');
  await response.close();
}
