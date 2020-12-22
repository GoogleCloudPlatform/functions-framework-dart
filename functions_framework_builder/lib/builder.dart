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
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:functions_framework/functions_framework.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import 'src/constants.dart';
import 'src/function_type_validator.dart';
import 'src/supported_function_type.dart';

Builder functionsFrameworkBuilder([BuilderOptions options]) =>
    const _FunctionsFrameworkBuilder();

class _FunctionsFrameworkBuilder implements Builder {
  const _FunctionsFrameworkBuilder();

  @override
  Map<String, List<String>> get buildExtensions => const {
        r'lib/functions.dart': ['bin/server.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final entries = <String, FactoryData>{};

    final input = buildStep.inputId;

    final libraryElement = await buildStep.resolver.libraryFor(input);
    final validator = await FunctionTypeValidator.create(buildStep.resolver);

    for (var annotatedElement in _fromLibrary(libraryElement)) {
      final element = annotatedElement.element;
      if (element is! FunctionElement || element.isPrivate) {
        throw InvalidGenerationSourceError(
          'Only top-level, public functions are supported.',
          element: element,
        );
      }

      final function = element as FunctionElement;

      final targetReader = annotatedElement.annotation.read('target');

      final targetName =
          targetReader.isNull ? function.name : targetReader.stringValue;

      if (entries.containsKey(targetName)) {
        throw InvalidGenerationSourceError(
          'A function has already been annotated with target "$targetName".',
          element: element,
        );
      }

      final invokeExpression = validator.validate(
        libraryElement,
        targetName,
        function,
      );

      entries[targetName] = invokeExpression;
    }

    final functions = <String>[];
    final factories = <String>[];
    for (var e in entries.values) {
      final factory = e.createFactory(functions.length);
      if (factory != null) {
        factories.add(factory);
      }
      functions.add('  ${e.createReference(functions.length)},');
    }

    var output = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
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

import 'package:functions_framework/serve.dart';
import '${input.uri}' as $functionsLibraryPrefix;

Future<void> main(List<String> args) async {
  await serve(args, _functionTargets);
}

const _functionTargets = <FunctionTarget>{
${functions.join('\n')}
};

${factories.join('\n')}
''';

    output = DartFormatter().format(output);

    await buildStep.writeAsString(
      AssetId(
        buildStep.inputId.package,
        path.join('bin', 'server.dart'),
      ),
      output,
    );
  }
}

Iterable<AnnotatedElement> _fromLibrary(LibraryElement library) sync* {
  // Merging the `topLevelElements` picks up private elements and fields.
  // While neither is supported, it allows us to provide helpful errors if devs
  // are using the annotations incorrectly.
  final mergedElements = {
    ...library.topLevelElements,
    ...library.exportNamespace.definedNames.values,
  };

  for (var element in mergedElements) {
    final annotations = _checker.annotationsOf(element).toList();

    if (annotations.isEmpty) {
      continue;
    }
    if (annotations.length > 1) {
      throw InvalidGenerationSourceError(
        'Cannot be annotated with `CloudFunction` more than once.',
        element: element,
      );
    }
    yield AnnotatedElement(ConstantReader(annotations.single), element);
  }
}

const _checker = TypeChecker.fromRuntime(CloudFunction);
