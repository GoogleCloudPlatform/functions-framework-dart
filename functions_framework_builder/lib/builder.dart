// Copyright 2020 Google LLC
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
