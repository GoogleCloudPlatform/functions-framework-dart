import 'dart:async';

import 'package:shelf/shelf.dart';

class MiddlewareTarget {
  final Middleware _middleware;

  FutureOr<Response> Function(Request request) handler(
    FutureOr<Response> Function(Request request) handler,
  ) =>
      _middleware(handler);

  MiddlewareTarget(this._middleware);
}
