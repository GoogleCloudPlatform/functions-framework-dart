import 'dart:async';
import 'dart:io' show ProcessSignal, exit, InternetAddress;

import 'package:reflectable/reflectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'configuration.dart';

Future<void> serve(
  FunctionConfig functionConfig,
  LibraryMirror functionLibrary,
) async {
  _handleSignals();

  final handler = _getHandler(functionConfig, functionLibrary);

  final server = await shelf_io.serve(
    (request) {
      return handler(functionLibrary, functionConfig.target, request);
    },
    InternetAddress.anyIPv4,
    functionConfig.port,
  );
  print('App listening on :${server.port}');
}

FutureOr<Response> Function(
        LibraryMirror functionLibrary, String target, Request request)
    _getHandler(FunctionConfig functionConfig, LibraryMirror functionLibrary) {
  if (!functionLibrary.declarations.containsKey(functionConfig.target)) {
    throw ArgumentError('Function target not found: ${functionConfig.target}.');
  }
  final handler = _handler(functionConfig.functionType);
  // TODO: validate function signature
  return handler;
}

FutureOr<Response> Function(LibraryMirror, String, Request) _handler(
    FunctionType functionType) {
  switch (functionType) {
    case FunctionType.http:
      return _handleRequest;
    case FunctionType.event:
    // TODO
    default:
      throw UnsupportedError(
        'Function type $functionType is not supported yet',
      );
  }
}

FutureOr<Response> _handleRequest(
  LibraryMirror functionLibrary,
  String target,
  Request request,
) async {
  if (request.method == 'GET') {
    // TODO: must 404 for /robots.txt and /favicon.ico
    final response = await functionLibrary.invoke(target, <dynamic>[request]);
    return response as Response;
  } else {
    return Response(405, body: 'Unsupported request: ${request.method}.');
  }
}

// the user's function app
class FunctionLibrary extends Reflectable {
  const FunctionLibrary()
      : super(
          topLevelInvokeCapability,
          libraryCapability,
          declarationsCapability,
        );
}

// annotation for the function app
const function = FunctionLibrary();

void _handleSignals() {
  ProcessSignal.sigint.watch().listen((signal) {
    exit(0);
  });
  ProcessSignal.sigterm.watch().listen((signal) {
    exit(0);
  });
}
