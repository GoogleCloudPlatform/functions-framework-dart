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
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'constants.dart';

class SupportedFunctionTypes {
  final List<_SupportedFunctionType> _types;

  SupportedFunctionTypes._(this._types);

  String validate(String targetName, FunctionElement element) {
    for (var type in _types) {
      if (type.compatible(element)) {
        return type.createReference(targetName, element);
      }
    }
    throw InvalidGenerationSourceError(
      '''
Not compatible with a supported function shape:
${_types.map((e) => '  ${e.name} [${e.typeDescription}] from ${e.library}').join('\n')}
''',
      element: element,
    );
  }

  static Future<SupportedFunctionTypes> create(Resolver resolver) async =>
      SupportedFunctionTypes._(
        [
          await _SupportedFunctionType.create(
            resolver,
            'package:shelf/shelf.dart',
            'Handler',
            'FunctionEndpoint.http',
          ),
          await _SupportedFunctionType.create(
            resolver,
            'package:functions_framework/functions_framework.dart',
            'CloudEventHandler',
            'FunctionEndpoint.cloudEvent',
          ),
        ],
      );
}

class _SupportedFunctionType {
  final String library;
  final String name;
  final FunctionType type;
  final String typeDescription;
  final String constructor;

  _SupportedFunctionType(
    this.library,
    this.name,
    this.type, {
    this.constructor,
  }) : typeDescription = type.getDisplayString(withNullability: false);

  static Future<_SupportedFunctionType> create(
    Resolver resolver,
    String libraryUri,
    String typeDefName,
    String constructor,
  ) async {
    final lib = await resolver.libraryFor(
      AssetId.resolve(libraryUri),
    );

    final handlerTypeAlias =
        lib.exportNamespace.get(typeDefName) as FunctionTypeAliasElement;

    final functionType = handlerTypeAlias.instantiate(
      typeArguments: [],
      nullabilitySuffix: NullabilitySuffix.none,
    );

    return _SupportedFunctionType(
      libraryUri,
      typeDefName,
      functionType,
      constructor: constructor,
    );
  }

  bool compatible(FunctionElement function) =>
      function.library.typeSystem.isSubtypeOf(
        function.type,
        type,
      );

  String createReference(String targetName, FunctionElement element) =>
      "$constructor('$targetName', $functionsLibraryPrefix.${element.name},)";
}
