// Copyright 2020 Google LLC
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

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'src/function_config.dart';

Future<void> serve(
  List<String> args,
  Map<String, Handler> handlers,
) async {
  final functionConfig =
      FunctionConfig.fromArgs(args, defaults: FunctionConfig.fromEnv());

  final handler = handlers[functionConfig.target];

  if (handler == null) {
    throw StateError(
      'There is no handler configured for '
      'FUNCTION_TARGET `${functionConfig.target}`.',
    );
  }

  // TODO: handle case where `handler` is null

  final pipeline =
      const Pipeline().addMiddleware(logRequests()).addHandler(handler);

  var server = await shelf_io.serve(
    pipeline,
    InternetAddress.anyIPv4,
    functionConfig.port,
  );
  print('App listening on :${server.port}');

  StreamSubscription sigIntSub, sigTermSub;

  Future<void> signalHandler(ProcessSignal signal) async {
    print('Got signal $signal - closing');

    final serverCopy = server;
    if (serverCopy != null) {
      server = null;
      await serverCopy.close(force: true);
      await sigIntSub.cancel();
      sigIntSub = null;
      await sigTermSub.cancel();
      sigTermSub = null;
    }
  }

  sigIntSub = ProcessSignal.sigint.watch().listen(signalHandler);
  sigTermSub = ProcessSignal.sigterm.watch().listen(signalHandler);
}
