// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'package:build/build.dart';
import 'package:functions_framework/functions_framework.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

Builder functionsFrameworkBuilder(BuilderOptions options) =>
    FunctionsFrameworkGenerator();

const _checker = TypeChecker.fromRuntime(CloudFunction);

class FunctionsFrameworkGenerator implements Builder {
  static final _libFiles = Glob('lib/**');

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
        // TODO: validate that annotatedElement is "shape" of a shelf handler
        final target = annotatedElement.annotation.read('target').stringValue;
        // TODO: validate target is a valid name, and not a duplicate!

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
