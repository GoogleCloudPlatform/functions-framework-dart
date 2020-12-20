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

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generic_function_type.dart';
import 'supported_function_type.dart';

class FunctionTypeValidator {
  final List<SupportedFunctionType> _types;

  FunctionTypeValidator._(this._types);

  FactoryData validate(String targetName, FunctionElement element) {
    for (var type in _types) {
      final reference = type.createReference(targetName, element);
      if (reference != null) {
        return reference;
      }
    }
    throw InvalidGenerationSourceError(
      '''
Not compatible with a supported function shape:
${_types.map((e) => '  ${e.typedefName} [${e.typeDescription}] from ${e.libraryUri}').join('\n')}
''',
      element: element,
    );
  }

  static Future<FunctionTypeValidator> create(Resolver resolver) async =>
      FunctionTypeValidator._(
        [
          await SupportedFunctionType.create(
            resolver,
            'package:functions_framework/functions_framework.dart',
            'HandlerWithLogger',
            'FunctionTarget.httpWithLogger',
          ),
          await SupportedFunctionType.create(
            resolver,
            'package:shelf/shelf.dart',
            'Handler',
            'FunctionTarget.http',
          ),
          await SupportedFunctionType.create(
            resolver,
            'package:functions_framework/functions_framework.dart',
            'CloudEventWithContextHandler',
            'FunctionTarget.cloudEventWithContext',
          ),
          await SupportedFunctionType.create(
            resolver,
            'package:functions_framework/functions_framework.dart',
            'CloudEventHandler',
            'FunctionTarget.cloudEvent',
          ),
          await GenericFunctionType.createWithContext(resolver),
          await GenericFunctionType.create(resolver),
        ],
      );
}
