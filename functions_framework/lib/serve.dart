import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'src/function_config.dart';

Future<void> serve(
  List<String> args,
  Map<String, Handler> handlers,
) async {
  _handleSignals();

  final functionConfig = FunctionConfig.fromEnv();

  final handler = handlers[functionConfig.target];

  // TODO: handle case where `handler` is null

  final pipeline =
      const Pipeline().addMiddleware(logRequests()).addHandler(handler);

  final server = await shelf_io.serve(
    pipeline,
    InternetAddress.anyIPv4,
    functionConfig.port,
  );
  print('App listening on :${server.port}');
}

void _handleSignals() {
  ProcessSignal.sigint.watch().listen((signal) {
    exit(0);
  });
  ProcessSignal.sigterm.watch().listen((signal) {
    exit(0);
  });
}
