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

/// Provides the features needed to *execute* Cloud Functions.
///
/// Typically, this library is imported in `bin/server.dart` or similar.
///
/// While it's possible to use this library from hand-written code, you should
/// use
/// [package:functions_framework_builder](https://pub.dev/packages/functions_framework_builder)
/// to generate server code instead.
library serve;

import 'dart:async';
import 'dart:io';

import 'package:io/ansi.dart';
import 'package:io/io.dart';

import 'src/bad_configuration.dart';
import 'src/cloud_metadata.dart';
import 'src/function_config.dart';
import 'src/function_target.dart';
import 'src/logging.dart';
import 'src/run.dart';

export 'src/bad_request_exception.dart' show BadRequestException;
export 'src/function_target.dart'
    show FunctionTarget, JsonFunctionTarget, JsonWithContextFunctionTarget;

/// If there is an invalid configuration, [exitCode] will be set to a non-zero
/// value and the returned [Future] will completes quickly.
///
/// If there are no configuration errors, the returned [Future] will not
/// complete until the process has received signal [ProcessSignal.sigterm] or
/// [ProcessSignal.sigint].
Future<void> serve(
  List<String> args,
  FunctionTarget? Function(String) nameToFunctionTarget,
) async {
  try {
    await _serve(args, nameToFunctionTarget);
  } on BadConfigurationException catch (e) {
    stderr.writeln(red.wrap(e.message));
    if (e.details != null) {
      stderr.writeln(e.details);
    }
    exitCode = ExitCode.usage.code;
  }
}

Future<void> _serve(
  List<String> args,
  FunctionTarget? Function(String) nameToFunctionTarget,
) async {
  final configFromEnvironment = FunctionConfig.fromEnv();

  final config = FunctionConfig.fromArgs(
    args,
    defaults: configFromEnvironment,
  );

  final functionTarget = nameToFunctionTarget(config.target);
  if (functionTarget == null) {
    throw BadConfigurationException(
      'There is no handler configured for '
      '$environmentKeyFunctionTarget `${config.target}`.',
    );
  }

  if (functionTarget.type == FunctionType.cloudevent &&
      config.functionType == FunctionType.http) {
    // See https://github.com/GoogleCloudPlatform/functions-framework-conformance/issues/58
    throw BadConfigurationException(
      'The configured $environmentKeyFunctionTarget `${config.target}` has a '
      'function type of `cloudevent` which is not compatible with the '
      'configured $environmentKeyFunctionSignatureType of `http`.',
    );
  }

  final projectId = await CloudMetadata.projectId();
  final loggingMiddleware = createLoggingMiddleware(projectId);

  final completer = Completer<bool>.sync();

  // sigIntSub is copied below to avoid a race condition - ignoring this lint
  // ignore: cancel_subscriptions
  StreamSubscription<ProcessSignal>? sigIntSub, sigTermSub;

  Future<void> signalHandler(ProcessSignal signal) async {
    print('Received signal $signal - closing');

    final subCopy = sigIntSub;
    if (subCopy != null) {
      sigIntSub = null;
      await subCopy.cancel();
      sigIntSub = null;
      if (sigTermSub != null) {
        await sigTermSub!.cancel();
        sigTermSub = null;
      }
      completer.complete(true);
    }
  }

  sigIntSub = ProcessSignal.sigint.watch().listen(signalHandler);

  // SIGTERM is not supported on Windows. Attempting to register a SIGTERM
  // handler raises an exception.
  if (!Platform.isWindows) {
    sigTermSub = ProcessSignal.sigterm.watch().listen(signalHandler);
  }

  await run(
      config.port, functionTarget.handler, completer.future, loggingMiddleware);
}
