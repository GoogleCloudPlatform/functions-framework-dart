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

import 'dart:io';

import 'package:args/args.dart';
import 'package:gcp/gcp.dart';

const defaultFunctionType = FunctionType.http;
const defaultFunctionTarget = 'function';

const environmentKeyFunctionTarget = 'FUNCTION_TARGET';
const environmentKeyFunctionSignatureType = 'FUNCTION_SIGNATURE_TYPE';

const _portOpt = 'port';
const _targetOpt = 'target';
const _functionTypeOpt = 'signature-type';

enum FunctionType {
  http,
  cloudevent,
}

class FunctionConfig {
  final int port;
  final FunctionType functionType;
  final String target;

  FunctionConfig({
    this.port = defaultListenPort,
    this.functionType = defaultFunctionType,
    this.target = defaultFunctionTarget,
  });

  // Required per spec:
  // https://github.com/GoogleCloudPlatform/functions-framework#specification-summary
  factory FunctionConfig.fromEnv() => FunctionConfig(
        port: listenPort(),
        target: Platform.environment[environmentKeyFunctionTarget] ??
            defaultFunctionTarget,
        functionType: _parseFunctionType(
          Platform.environment['FUNCTION_SIGNATURE_TYPE'] ??
              _enumValue(FunctionType.http),
        ),
      );

  // Optional per spec:
  // https://github.com/GoogleCloudPlatform/functions-framework#specification-summary
  factory FunctionConfig.fromArgs(
    List<String> args, {
    FunctionConfig? defaults,
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
            'Overrides the $environmentKeyFunctionTarget environment variable.',
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
      port = defaults?.port ?? defaultListenPort;
    }

    final functionTypeOptionValue = options[_functionTypeOpt] as String?;

    return FunctionConfig(
      port: port,
      target: options[_targetOpt] as String? ??
          defaults?.target ??
          defaultFunctionTarget,
      functionType: functionTypeOptionValue == null
          ? defaults?.functionType ?? defaultFunctionType
          : _parseFunctionType(functionTypeOptionValue),
    );
  }
}

FunctionType _parseFunctionType(String type) => FunctionType.values.singleWhere(
      (element) => type == _enumValue(element),
      orElse: () => throw BadConfigurationException(
        'FUNCTION_SIGNATURE_TYPE environment variable "$type" is not a valid '
        'option (must be "http" or "cloudevent")',
      ),
    );

String _enumValue(FunctionType enumEntry) {
  final v = enumEntry.toString();
  return v.substring(v.indexOf('.') + 1);
}
