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
import 'package:source_helper/source_helper.dart';

import 'constants.dart';

class SupportedFunctionType {
  final String libraryUri;
  final String typedefName;
  final String typeDescription;

  final FunctionType _type;
  final String? _constructor;

  SupportedFunctionType._(
    this.libraryUri,
    this.typedefName,
    this._type, {
    String? constructor,
  })  : _constructor = constructor,
        typeDescription = _type.getDisplayString(withNullability: false);

  static Future<SupportedFunctionType> create(
    Resolver resolver,
    String libraryUri,
    String typeDefName,
    String constructor,
  ) async {
    final lib = await resolver.libraryFor(
      AssetId.resolve(Uri.parse(libraryUri)),
    );

    final handlerTypeAlias =
        lib.exportNamespace.get(typeDefName) as TypeAliasElement;

    final functionType = handlerTypeAlias.instantiate(
      typeArguments: [],
      nullabilitySuffix: NullabilitySuffix.none,
    );

    return SupportedFunctionType._(
      libraryUri,
      typeDefName,
      functionType as FunctionType,
      constructor: constructor,
    );
  }

  FactoryData? createReference(
    LibraryElement library,
    String targetName,
    FunctionElement element,
  ) {
    if (element.library.typeSystem.isSubtypeOf(element.type, _type)) {
      return _TrivialFactoryData(
        escapeDartString(targetName),
        '$_constructor('
        '$functionsLibraryPrefix.${element.name},)',
      );
    }
    return null;
  }
}

abstract class FactoryData {
  String get name;

  String get expression;
}

class _TrivialFactoryData implements FactoryData {
  @override
  final String name;
  @override
  final String expression;

  _TrivialFactoryData(this.name, this.expression);
}
