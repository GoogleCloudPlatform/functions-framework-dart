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

import 'package:build/build.dart';
import 'package:functions_framework/functions_framework.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import 'src/utils.dart';

Builder functionsFrameworkBuilder([BuilderOptions options]) =>
    const _FunctionsFrameworkBuilder();

const _checker = TypeChecker.fromRuntime(CloudFunction);

class _FunctionsFrameworkBuilder implements Builder {
  static final _libFiles = Glob('lib/**');

  const _FunctionsFrameworkBuilder();

  @override
  Map<String, List<String>> get buildExtensions => const {
        r'$package$': ['bin/main.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final files = <_Entry>[];

    final libs = <Uri, String>{};

    await for (final input in buildStep.findAssets(_libFiles)) {
      final element = await buildStep.resolver.libraryFor(input);

      final reader = LibraryReader(element);
      for (var annotatedElement in reader.annotatedWithExact(_checker)) {
        validateHandlerShape(annotatedElement.element);
        final target = annotatedElement.annotation.read('target').stringValue;

        if (files.any((element) => element.target == target)) {
          throw InvalidGenerationSourceError(
            'A function has already been annotated with target "$target".',
            element: annotatedElement.element,
          );
        }

        libs.putIfAbsent(input.uri, () => _prefixFromIndex(libs.length));

        files.add(_Entry(
          input.uri,
          target,
          annotatedElement.element.name,
        ));
      }
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

${libs.entries.map((e) => "import '${e.key}' as ${e.value};").join('\n')}

Future<void> main(List<String> args) async {
  await serve(args, _functions);
}

const _functions = <String, Handler>{
${files.map((e) => "  '${e.target}': ${libs[e.uri]}.${e.functionName},").join('\n')}
};
''');
  }
}

class _Entry {
  final Uri uri;
  final String target;
  final String functionName;

  _Entry(
    this.uri,
    this.target,
    this.functionName,
  );
}

String _prefixFromIndex(int index) =>
    'prefix${index.toString().padLeft(2, '0')}';
