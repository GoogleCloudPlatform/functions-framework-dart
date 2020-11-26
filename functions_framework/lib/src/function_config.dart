// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';

import 'bad_configuration.dart';

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
  factory FunctionConfig.fromEnv() {
    int port;

    if (Platform.environment.containsKey('PORT')) {
      try {
        port = int.parse(Platform.environment['PORT']);
      } on FormatException catch (e) {
        throw BadConfigurationException(
          'Bad value for environment variable "PORT" – '
          '"${Platform.environment['PORT']}" – ${e.message}.',
        );
      }
    } else {
      port = defaultPort;
    }

    return FunctionConfig(
      port: port,
      target: Platform.environment['FUNCTION_TARGET'] ?? defaultFunctionTarget,
      functionType: _parseFunctionType(
        Platform.environment['FUNCTION_SIGNATURE_TYPE'] ??
            _enumValue(FunctionType.http),
      ),
    );
  }

  // Optional per spec:
  // https://github.com/GoogleCloudPlatform/functions-framework#specification-summary
  factory FunctionConfig.fromArgs(
    List<String> args, {
    FunctionConfig defaults,
  }) {
    final parser = ArgParser(usageLineLength: 80)
      ..addOption(
        _portOpt,
        help:
            'The port on which the Functions Framework listens for requests.\n'
            'Overrides the PORT environment variable.',
      )
      ..addOption(
        _targetOpt,
        help: 'The name of the exported function to be invoked in response to '
            'requests.\n'
            'Overrides the FUNCTION_TARGET environment variable.',
      )
      ..addOption(
        _functionTypeOpt,
        allowed: FunctionType.values.map(_enumValue),
        help: 'The signature used when writing your function. '
            'Controls unmarshalling rules and determines which arguments are '
            'used to invoke your function.\n'
            'Overrides the FUNCTION_SIGNATURE_TYPE environment variable.',
      );

    ArgResults options;
    try {
      options = parser.parse(args);
    } on FormatException catch (e) {
      throw BadConfigurationException(e.message, details: parser.usage);
    }

    int port;

    if (options.wasParsed(_portOpt)) {
      try {
        port = int.parse(options[_portOpt] as String);
      } on FormatException catch (e) {
        throw BadConfigurationException(
          'Bad value for "$_portOpt" – "${options[_portOpt]}" – ${e.message}.',
          details: parser.usage,
        );
      }
    } else {
      port = defaults?.port ?? defaultPort;
    }

    return FunctionConfig(
      port: port,
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
      throw BadConfigurationException(
        'FUNCTION_SIGNATURE_TYPE environment variable "$type" is not a valid '
        'option (must be "http" or "cloudevent")',
      );
  }
}

String _enumValue(Object enumEntry) {
  final v = enumEntry.toString();
  return v.substring(v.indexOf('.') + 1);
}
