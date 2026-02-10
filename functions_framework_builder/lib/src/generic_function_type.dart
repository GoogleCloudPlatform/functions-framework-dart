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
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import 'analyzer_utils.dart';
import 'constants.dart';
import 'supported_function_type.dart';
import 'valid_json_utils.dart';

const _libraryUrl = 'package:functions_framework/functions_framework.dart';
final _libraryUri = Uri.parse(_libraryUrl);
const _typedefName = 'JsonHandler';
const _typedefWithContextName = 'JsonWithContextHandler';

const _constructorName = 'JsonFunctionTarget';
const _voidConstructorName = '$_constructorName.voidResult';
const _withContextConstructorName = 'JsonWithContextFunctionTarget';
const _voidWithContextConstructorName =
    '$_withContextConstructorName.voidResult';

class GenericFunctionType implements SupportedFunctionType {
  @override
  String get libraryUri => _libraryUrl;

  @override
  String get typedefName => _typedefName;

  @override
  String get typeDescription =>
      _functionTypeAliasElement.aliasedElement!.toStringNonNullable();

  final TypeAliasElement _functionTypeAliasElement;
  final bool _withContext;

  GenericFunctionType._(this._functionTypeAliasElement, this._withContext);

  static Future<GenericFunctionType> create(Resolver resolver) async {
    final lib = await resolver.libraryFor(AssetId.resolve(_libraryUri));

    final handlerTypeAlias =
        lib.exportNamespace.get(_typedefName) as TypeAliasElement;

    return GenericFunctionType._(handlerTypeAlias, false);
  }

  static Future<GenericFunctionType> createWithContext(
    Resolver resolver,
  ) async {
    final lib = await resolver.libraryFor(AssetId.resolve(_libraryUri));

    final handlerTypeAlias =
        lib.exportNamespace.get(_typedefWithContextName) as TypeAliasElement;

    return GenericFunctionType._(handlerTypeAlias, true);
  }

  @override
  FactoryData? createReference(
    LibraryElement library,
    String targetName,
    FunctionElement element,
  ) {
    if (element.parameters.isEmpty) {
      return null;
    }

    final firstParamType = element.parameters.first.type;

    final paramInfo = validJsonParamType(firstParamType);

    if (paramInfo == null) {
      return null;
    }

    final returnKind = validJsonReturnType(element.returnType);

    if (returnKind == JsonReturnKind.notJson) {
      return null;
    }

    final functionType = _functionTypeAliasElement.instantiate(
      typeArguments: [firstParamType, element.returnType],
      nullabilitySuffix: NullabilitySuffix.none,
    );

    if (library.typeSystem.isSubtypeOf(element.type, functionType)) {
      if (paramInfo.paramType != null) {
        if (library.exportNamespace.get(paramInfo.paramType!.element.name) ==
            null) {
          // TODO: add a test for this!
          throw InvalidGenerationSourceError(
            'The type `${paramInfo.paramType!.element.name}` is not exposed '
            'by the function library `${library.source.uri}` so it cannot '
            'be used.',
          );
        }
      }

      return _GenericFactoryData(
        _withContext,
        returnKind == JsonReturnKind.isVoid,
        paramInfo,
        escapeDartString(targetName),
        '$functionsLibraryPrefix.${element.name}',
      );
    }
    return null;
  }
}

class _GenericFactoryData implements FactoryData {
  final String _endpointConstructorName;
  final String target;
  final String function;

  final String returnType;
  final String factoryBody;

  _GenericFactoryData._(
    this._endpointConstructorName,
    this.target,
    this.function,
    this.returnType,
    this.factoryBody,
  );

  factory _GenericFactoryData(
    bool withContext,
    bool isVoid,
    JsonParamInfo info,
    String target,
    String function,
  ) {
    final jsonTypeDisplay = info.jsonType.toStringNonNullable();
    final typeDisplayName =
        info.paramType == null
            ? jsonTypeDisplay
            : '$functionsLibraryPrefix.'
                '${info.paramType!.toStringNonNullable()}';

    final returnBlock =
        info.paramType == null
            ? 'return $_jsonParamName;'
            : '''
    try {
      return $typeDisplayName.$fromJsonFactoryName($_jsonParamName);
    } catch (e, stack) {
      throw BadRequestException(
        400,
        'There was an error parsing the provided JSON data.',
        innerError: e,
        innerStack: stack,
      );
    }
    ''';

    final body = '''
  if ($_jsonParamName is $jsonTypeDisplay) {
    $returnBlock
  }
  throw BadRequestException(
    400,
    'The provided JSON is not the expected type '
    '`$jsonTypeDisplay`.',
  );
''';

    return _GenericFactoryData._(
      isVoid
          ? withContext
              ? _voidWithContextConstructorName
              : _voidConstructorName
          : withContext
          ? _withContextConstructorName
          : _constructorName,
      target,
      function,
      typeDisplayName,
      body,
    );
  }

  @override
  String get expression => '''
$_endpointConstructorName($function, ($_jsonParamName) {
  $factoryBody
},)
''';

  @override
  String get name => target;
}

const _jsonParamName = 'json';
