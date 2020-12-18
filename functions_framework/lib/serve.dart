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

import 'dart:async';
import 'dart:io';

import 'package:io/ansi.dart';
import 'package:io/io.dart';

import 'src/bad_configuration.dart';
import 'src/cloud_metadata.dart';
import 'src/function_config.dart';
import 'src/function_endpoint.dart';
import 'src/logging.dart';
import 'src/run.dart';

export 'src/bad_request_exception.dart' show BadRequestException;
export 'src/custom_event_wrapper.dart'
    show CustomTypeFunctionEndPoint, VoidCustomTypeFunctionEndPoint;
export 'src/function_endpoint.dart' show FunctionEndpoint;

/// If there is an invalid configuration, [BadConfigurationException] will be
/// thrown.
///
/// If there are no configuration errors, this function will not return until
/// the process has received signal [ProcessSignal.sigterm] or
/// [ProcessSignal.sigint].
Future<void> serve(List<String> args, Set<FunctionEndpoint> functions) async {
  try {
    await _serve(args, functions);
  } on BadConfigurationException catch (e) {
    stderr.writeln(red.wrap(e.message));
    if (e.details != null) {
      stderr.writeln(e.details);
    }
    exitCode = ExitCode.usage.code;
  }
}

Future<void> _serve(List<String> args, Set<FunctionEndpoint> functions) async {
  final configFromEnvironment = FunctionConfig.fromEnv();

  final config = FunctionConfig.fromArgs(
    args,
    defaults: configFromEnvironment,
  );

  final function = functions.singleWhere(
    (element) => element.target == config.target,
    orElse: () => throw BadConfigurationException(
      'There is no handler configured for '
      '$environmentKeyFunctionTarget `${config.target}`.',
    ),
  );

  if (function.functionType == FunctionType.cloudevent &&
      config.functionType == FunctionType.http) {
    // See https://github.com/GoogleCloudPlatform/functions-framework-conformance/issues/58
    stderr.writeln(
      'The configured $environmentKeyFunctionTarget `${config.target}` has a '
      'function type of `cloudevent` which is not compatible with the '
      'configured $environmentKeyFunctionSignatureType of `http`.',
    );
    exitCode = ExitCode.usage.code;
    return;
  }

  final projectId = await CloudMetadata.projectId();
  final loggingMiddleware = createLoggingMiddleware(projectId);

  final completer = Completer<bool>.sync();

  // sigIntSub is copied below to avoid a race condition - ignoring this lint
  // ignore: cancel_subscriptions
  StreamSubscription sigIntSub, sigTermSub;

  Future<void> signalHandler(ProcessSignal signal) async {
    print('Received signal $signal - closing');

    final subCopy = sigIntSub;
    if (subCopy != null) {
      sigIntSub = null;
      await subCopy.cancel();
      sigIntSub = null;
      await sigTermSub.cancel();
      sigTermSub = null;
      completer.complete(true);
    }
  }

  sigIntSub = ProcessSignal.sigint.watch().listen(signalHandler);
  sigTermSub = ProcessSignal.sigterm.watch().listen(signalHandler);

  await run(config.port, function.handler, completer.future, loggingMiddleware);
}
