import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<void> run(int port, Handler handler) async {
  final pipeline =
      const Pipeline().addMiddleware(logRequests()).addHandler(handler);

  var server = await shelf_io.serve(
    pipeline,
    InternetAddress.anyIPv4,
    port,
  );
  print('App listening on :${server.port}');

  final completer = Completer<void>.sync();

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
      completer.complete();
    }
  }

  sigIntSub = ProcessSignal.sigint.watch().listen(signalHandler);
  sigTermSub = ProcessSignal.sigterm.watch().listen(signalHandler);

  await completer.future;
}
