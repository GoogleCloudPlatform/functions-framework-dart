// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'cloud_metadata.dart';
import 'logging.dart';

Future<void> run(int port, Handler handler) async {
  final pipeline = const Pipeline()
      .addMiddleware(loggingMiddleware())
      .addMiddleware(_forbiddenAssetMiddleware)
      .addHandler(handler);

  final metadataThing = CloudMetadata();
  try {
    final recursive = await metadataThing.recursive();
    print(const JsonEncoder.withIndent('  ').convert(recursive));
  } finally {
    metadataThing.close();
  }

  var server = await shelf_io.serve(
    pipeline,
    InternetAddress.anyIPv4,
    port,
  );
  print('Listening on :${server.port}');

  final completer = Completer<void>.sync();

  StreamSubscription sigIntSub, sigTermSub;

  Future<void> signalHandler(ProcessSignal signal) async {
    print('Received signal $signal - closing');

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

const _forbiddenAssets = {'robots.txt', 'favicon.ico'};

Handler _forbiddenAssetMiddleware(Handler innerHandler) => (Request request) {
      if (_forbiddenAssets.contains(request.url.path)) {
        return Response.notFound('Not found.');
      }
      return innerHandler(request);
    };
