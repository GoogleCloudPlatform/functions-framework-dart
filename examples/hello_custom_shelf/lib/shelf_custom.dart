import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

FutureOr<HttpServer> shelfServer(Handler handler) async {
  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_forbiddenAssetMiddleware)
      .addHandler(handler);

  return await serve(
    pipeline,
    InternetAddress.anyIPv4,
    8090,
  );
}

const _forbiddenAssets = {'robots.txt', 'favicon.ico'};

Handler _forbiddenAssetMiddleware(Handler innerHandler) => (Request request) {
      if (_forbiddenAssets.contains(request.url.path)) {
        return Response.notFound('Not found.');
      }
      return innerHandler(request);
    };
