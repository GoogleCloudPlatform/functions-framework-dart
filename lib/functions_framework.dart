import 'dart:io';

import 'package:reflectable/reflectable.dart';

import 'configuration.dart';

Future<void> serve(
  FunctionConfig functionConfig,
  LibraryMirror functionLibrary,
) async {
  handleSignals();

  final handler = getHandler(functionConfig, functionLibrary);

  final server = await HttpServer.bind(
    InternetAddress.anyIPv4,
    functionConfig.port,
  );
  print('App listening on :${server.port}');

  await for (var request in server) {
    await handler(functionLibrary, functionConfig.target, request);
  }
}

Function(LibraryMirror functionLibrary, String target, HttpRequest request)
    getHandler(FunctionConfig functionConfig, LibraryMirror functionLibrary) {
  if (!functionLibrary.declarations.containsKey(functionConfig.target)) {
    throw ArgumentError('Function target not found: ${functionConfig.target}.');
  }
  final handler = _handler(functionConfig.functionType);
  // TODO: validate function signature
  return handler;
}

Future<void> Function(LibraryMirror, String, HttpRequest) _handler(
    FunctionType functionType) {
  switch (functionType) {
    case FunctionType.http:
      return handleRequest;
    case FunctionType.event:
    // TODO
    default:
      throw UnsupportedError(
        'Function type $functionType is not supported yet',
      );
  }
}

Future<void> handleRequest(
  LibraryMirror functionLibrary,
  String target,
  HttpRequest request,
) async {
  print('Handling request: ${request.requestedUri.path}');
  try {
    if (request.method == 'GET') {
      // TODO: must 404 for /robots.txt and /favicon.ico
      await functionLibrary.invoke(target, <dynamic>[request]);
      print('Request handled');
    } else {
      request.response
        ..statusCode = HttpStatus.methodNotAllowed
        ..write('Unsupported request: ${request.method}.');
      await request.response.close();
    }
  } catch (e) {
    print('Exception handling request: $e');
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

void handleSignals() {
  ProcessSignal.sigint.watch().listen((signal) {
    exit(0);
  });
  ProcessSignal.sigterm.watch().listen((signal) {
    exit(0);
  });
}
