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

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<void> run(
  int port,
  Handler handler,
  Future<bool> shutdownSignal,
  Middleware loggingMiddleware, {
  bool autoCompress = false,
  List<Middleware> middlewares = const [],
}) async {
  for (var m in middlewares) {
    loggingMiddleware.addMiddleware(m);
  }

  final server = await shelf_io.serve(
    loggingMiddleware
        .addMiddleware(_forbiddenAssetMiddleware)
        .addHandler(handler),
    InternetAddress.anyIPv4,
    port,
  );
  server.autoCompress = autoCompress;
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
