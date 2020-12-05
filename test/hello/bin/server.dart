// GENERATED CODE - DO NOT MODIFY BY HAND
// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'package:functions_framework/serve.dart';
import 'package:shelf/shelf.dart';

import 'package:hello_world_function_test/functions.dart' as function_library;

Future<void> main(List<String> args) async {
  await serve(args, _functions);
}

const _functions = <String, Handler>{
  'function': function_library.handleGet,
  'conformance': function_library.conformance,
};
