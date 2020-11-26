// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:io/ansi.dart';
import 'package:io/io.dart';
import 'package:shelf/shelf.dart';

import 'src/bad_configuration.dart';
import 'src/function_config.dart';
import 'src/run.dart';

/// If there is an invalid configuration, [BadConfigurationException] will be
/// thrown.
///
/// If there are no configuration errors, this function will not return until
/// the process has received signal [ProcessSignal.sigterm] or
/// [ProcessSignal.sigint].
Future<void> serve(List<String> args, Map<String, Handler> handlers) async {
  try {
    await _serve(args, handlers);
  } on BadConfigurationException catch (e) {
    stderr.writeln(red.wrap(e.message));
    if (e.details != null) {
      stderr.writeln(e.details);
    }
    exitCode = ExitCode.usage.code;
  }
}

Future<void> _serve(List<String> args, Map<String, Handler> handlers) async {
  final configFromEnvironment = FunctionConfig.fromEnv();

  final config = FunctionConfig.fromArgs(
    args,
    defaults: configFromEnvironment,
  );

  final handler = handlers[config.target];

  if (handler == null) {
    throw BadConfigurationException(
      'There is no handler configured for '
      'FUNCTION_TARGET `${config.target}`.',
    );
  }

  await run(config.port, handler);
}
