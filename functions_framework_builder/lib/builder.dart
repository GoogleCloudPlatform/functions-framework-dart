// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

/// Configuration for using `package:build`-compatible build systems.
///
/// See:
/// * [build_runner](https://pub.dev/packages/build_runner)
///
/// This library is **not** intended to be imported by typical end-users unless
/// you are creating a custom compilation pipeline. See documentation for
/// details, and `build.yaml` for how this builder is configured by default.
library functions_framework_builder.builder;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:functions_framework/functions_framework.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

Builder functionsFrameworkBuilder([BuilderOptions options]) =>
    const _FunctionsFrameworkBuilder();

const _checker = TypeChecker.fromRuntime(CloudFunction);

class _FunctionsFrameworkBuilder implements Builder {
  const _FunctionsFrameworkBuilder();

  @override
  Map<String, List<String>> get buildExtensions => const {
        r'lib/library.dart': ['bin/main.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final entries = <String, String>{};

    final input = buildStep.inputId;

    final element = await buildStep.resolver.libraryFor(input);

    final reader = LibraryReader(element);

    final handlerFunctionType = await _shelfHandler(buildStep.resolver);

    for (var annotatedElement in reader.annotatedWithExact(_checker)) {
      await _validateHandlerShape(
          annotatedElement.element, handlerFunctionType);
      final target = annotatedElement.annotation.read('target').stringValue;

      if (entries.containsKey(target)) {
        throw InvalidGenerationSourceError(
          'A function has already been annotated with target "$target".',
          element: annotatedElement.element,
        );
      }

      entries[target] = annotatedElement.element.name;
    }

    // bin/main.dart
    final mainDart = AssetId(
      buildStep.inputId.package,
      path.join('bin', 'main.dart'),
    );
    await buildStep.writeAsString(mainDart, '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'package:functions_framework/serve.dart';
import 'package:shelf/shelf.dart';

import '${input.uri}' as function_library;

Future<void> main(List<String> args) async {
  await serve(args, _functions);
}

const _functions = <String, Handler>{
${entries.entries.map((e) => "  '${e.key}': function_library.${e.value},").join('\n')}
};
''');
  }
}

Future<FunctionType> _shelfHandler(Resolver resolver) async {
  final shelfLib = await resolver.libraries.singleWhere(
    (element) => element.source.uri == Uri.parse('package:shelf/shelf.dart'),
  );

  final handlerTypeAlias =
      shelfLib.exportNamespace.get('Handler') as FunctionTypeAliasElement;

  return handlerTypeAlias.instantiate(
    typeArguments: [],
    nullabilitySuffix: NullabilitySuffix.none,
  );
}

Future<void> _validateHandlerShape(
  Element element,
  FunctionType handlerFunctionType,
) async {
  if (element is! FunctionElement) {
    throw InvalidGenerationSourceError(
      'Only top-level functions are supported.',
      element: element,
    );
  }
  final func = element as FunctionElement;

  final compatible = func.library.typeSystem.isSubtypeOf(
    func.type,
    handlerFunctionType,
  );

  if (!compatible) {
    final str = handlerFunctionType.getDisplayString(withNullability: false);
    throw InvalidGenerationSourceError(
      'Not compatible with package:shelf Handler `$str`.',
      element: element,
    );
  }
}
