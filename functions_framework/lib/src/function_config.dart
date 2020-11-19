import 'dart:io';

const defaultPort = 8080;
const defaultFunctionType = FunctionType.http;
const defaultFunctionTarget = 'function';

enum FunctionType {
  event,
  http,
}

class FunctionConfig {
  final int port;
  final FunctionType functionType;
  final String target;

  FunctionConfig({
    this.port = defaultPort,
    this.functionType = defaultFunctionType,
    this.target = defaultFunctionTarget,
  });

  // TODO: this should take `List<String> args` and use an arg parser
  // per https://github.com/GoogleCloudPlatform/functions-framework#specification-summary
  factory FunctionConfig.fromEnv() => FunctionConfig(
        port: int.tryParse(
            Platform.environment['PORT'] ?? defaultPort.toString()),
        functionType: _parseFunctionType(
            Platform.environment['FUNCTION_SIGNATURE_TYPE'] ??
                _enumValue(FunctionType.http)),
        target:
            Platform.environment['FUNCTION_TARGET'] ?? defaultFunctionTarget,
      );
}

FunctionType _parseFunctionType(String type) {
  type ??= '';
  switch (type) {
    case '':
      return defaultFunctionType;
    case 'http':
      return FunctionType.http;
    case 'event':
      return FunctionType.event;
    default:
      throw UnsupportedError(
        'FUNCTION_SIGNATURE_TYPE environment variable "$type" is not a valid '
        'option (must be "http" or "event")',
      );
  }
}

String _enumValue(Object enumEntry) {
  final v = enumEntry.toString();
  return v.substring(v.indexOf('.') + 1);
}
