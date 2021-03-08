import 'dart:async';
import 'dart:io';
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

void shelfServer(FunctionConfig config, Handler handler,
    FutureOr<bool> shutdownSignal) async {
  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_forbiddenAssetMiddleware)
      .addHandler(handler);

  final server = await serve(
    pipeline,
    InternetAddress.anyIPv4,
    8090,
  );

  print('Listening on ${server.address.host}:${server.port}');

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
