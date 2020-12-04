// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<void> run(
  int port,
  Handler handler,
  Future<bool> shutdownSignal,
  Middleware loggingMiddleware,
) async {
  final pipeline = const Pipeline()
      .addMiddleware(loggingMiddleware)
      .addMiddleware(_forbiddenAssetMiddleware)
      .addHandler(handler);

  final server = await shelf_io.serve(
    pipeline,
    InternetAddress.anyIPv4,
    port,
  );
  print('Listening on :${server.port}');

  final force = await shutdownSignal;
  await server.close(force: force);
}

const _forbiddenAssets = {'robots.txt', 'favicon.ico'};

Handler _forbiddenAssetMiddleware(Handler innerHandler) => (Request request) {
      if (_forbiddenAssets.contains(request.url.path)) {
        return Response.notFound('Not found.');
      }
      return innerHandler(request);
    };
