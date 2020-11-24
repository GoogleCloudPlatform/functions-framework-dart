// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';

const defaultPort = 8080;
const defaultFunctionType = FunctionType.http;
const defaultFunctionTarget = 'function';

const _portOpt = 'port';
const _targetOpt = 'target';
const _functionTypeOpt = 'signature-type';

enum FunctionType {
  http,
  cloudEvent,
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

  // Required per spec:
  // https://github.com/GoogleCloudPlatform/functions-framework#specification-summary
  factory FunctionConfig.fromEnv() => FunctionConfig(
        port: int.tryParse(
            Platform.environment['PORT'] ?? defaultPort.toString()),
        target:
            Platform.environment['FUNCTION_TARGET'] ?? defaultFunctionTarget,
        functionType: _parseFunctionType(
          Platform.environment['FUNCTION_SIGNATURE_TYPE'] ??
              _enumValue(FunctionType.http),
        ),
      );

  // Optional per spec:
  // https://github.com/GoogleCloudPlatform/functions-framework#specification-summary
  factory FunctionConfig.fromArgs(
    List<String> args, {
    FunctionConfig defaults,
  }) {
    final parser = ArgParser()
      ..addOption(_portOpt)
      ..addOption(_targetOpt)
      ..addOption(_functionTypeOpt);

    final options = parser.parse(args);

    return FunctionConfig(
      port: (options[_portOpt] != null)
          ? int.tryParse(options[_portOpt] as String)
          : defaults?.port ?? defaultPort,
      target: options[_targetOpt] as String ??
          defaults?.target ??
          defaultFunctionTarget,
      functionType: _parseFunctionType(options[_functionTypeOpt] as String) ??
          defaults?.functionType ??
          defaultFunctionType,
    );
  }
}

FunctionType _parseFunctionType(String type) {
  type ??= '';
  switch (type) {
    case '':
      return defaultFunctionType;
    case 'http':
      return FunctionType.http;
    case 'cloudevent':
      return FunctionType.cloudEvent;
    default:
      throw UnsupportedError(
        'FUNCTION_SIGNATURE_TYPE environment variable "$type" is not a valid '
        'option (must be "http" or "cloudevent")',
      );
  }
}

String _enumValue(Object enumEntry) {
  final v = enumEntry.toString();
  return v.substring(v.indexOf('.') + 1);
}
