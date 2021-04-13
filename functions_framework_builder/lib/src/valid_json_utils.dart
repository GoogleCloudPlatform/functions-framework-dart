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

import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';

const fromJsonFactoryName = 'fromJson';

bool _validJsonType(DartType type, bool allowComplexMembers) {
  bool validCollectionMember(DartType memberType) {
    if (allowComplexMembers) {
      return memberType.isDynamic ||
          memberType.isDartCoreObject ||
          _validJsonReturnTypeCore(memberType) == JsonReturnKind.other;
    }
    return memberType.isDynamic || memberType.isDartCoreObject;
  }

  if (type.isDartCoreBool ||
      type.isDartCoreNum ||
      type.isDartCoreDouble ||
      type.isDartCoreInt ||
      type.isDartCoreString) {
    return true;
  }

  if (type is InterfaceType) {
    if (type.isDartCoreList) {
      final arg = type.typeArguments.single;
      return validCollectionMember(arg);
    } else if (type.isDartCoreMap) {
      final keyArg = type.typeArguments[0];
      final valueArg = type.typeArguments[1];
      return keyArg.isDartCoreString && validCollectionMember(valueArg);
    }
  }
  return false;
}

class JsonParamInfo {
  final DartType jsonType;
  final InterfaceType? paramType;

  JsonParamInfo._(this.jsonType, this.paramType);
}

JsonParamInfo? validJsonParamType(DartType type) {
  // Look for a `fromJson` factory that takes a JSON-able type
  if (type is InterfaceType) {
    final fromJsonCtor = type.constructors.singleWhereOrNull(
      (element) => element.name == fromJsonFactoryName,
    );
    if (fromJsonCtor != null) {
      final requiredParams = fromJsonCtor.parameters
          .where((element) => element.isRequiredPositional)
          .toList();
      if (requiredParams.length == 1) {
        final paramType = requiredParams.single.type;
        if (_validJsonType(paramType, false)) {
          return JsonParamInfo._(paramType, type);
        }
      }
    }
  }

  if (_validJsonType(type, false)) {
    return JsonParamInfo._(type, null);
  }
  return null;
}

enum JsonReturnKind { isVoid, notJson, other }

JsonReturnKind validJsonReturnType(DartType type) {
  if (type.isDartAsyncFuture || type.isDartAsyncFutureOr) {
    // Unwrap the future value and run again!
    return _validJsonReturnTypeCore(
        (type as InterfaceType).typeArguments.single);
  }

  return _validJsonReturnTypeCore(type);
}

JsonReturnKind _validJsonReturnTypeCore(DartType type) {
  if (type.isVoid) {
    return JsonReturnKind.isVoid;
  }

  // Look for a `toJson` function that returns a JSON-able type
  if (type is InterfaceType) {
    final toJsonMethod = [
      type.getMethod('toJson'),
      ...type.mixins.map((mixin) => mixin.getMethod('toJson'))
    ].firstWhere(
        (element) =>
            element != null &&
            element.parameters.every((element) => element.isOptional),
        orElse: () => null);
    if (toJsonMethod != null) type = toJsonMethod.returnType;
  }

  return _validJsonType(type, true)
      ? JsonReturnKind.other
      : JsonReturnKind.notJson;
}
