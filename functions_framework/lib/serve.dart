// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

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
