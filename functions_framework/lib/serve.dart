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
import 'package:shelf/shelf.dart';

import 'src/bad_configuration.dart';
import 'src/cloud_metadata.dart';
import 'src/function_config.dart';
import 'src/logging.dart';
import 'src/run.dart';

export 'src/cloud_event_wrapper.dart' show wrapCloudEventHandler;

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

  final projectId = await CloudMetadata.projectId();
  final loggingMiddleware =
      projectId == null ? logRequests() : cloudLoggingMiddleware(projectId);

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

  await run(config.port, handler, completer.future, loggingMiddleware);
}
