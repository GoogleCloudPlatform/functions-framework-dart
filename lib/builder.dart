import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

Builder functionsFrameworkBuilder(BuilderOptions options) =>
    FunctionsFrameworkGenerator();

class FunctionsFrameworkGenerator implements Builder {
  static final _libFiles = Glob('lib/**');

  @override
  Map<String, List<String>> get buildExtensions => const {
        r'$package$': ['bin/main.dart', 'bin/reflectable.build.yaml'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final files = <String>[];

    // for now we assume all source files are under lib
    await for (final input in buildStep.findAssets(_libFiles)) {
      files.add(input.uri.toString());
    }

    // bin/main.dart
    final main_dart = AssetId(
      buildStep.inputId.package,
      path.join('bin', 'main.dart'),
    );
    await buildStep.writeAsString(main_dart, '''
import 'package:functions_framework_dart/configuration.dart';
import 'package:functions_framework_dart/functions_framework.dart';

import '${files[0]}' as app;

import 'main.reflectable.dart' as reflectable;

Future main(List<String> args) async {
  reflectable.initializeReflectable();
  final functionConfig = FunctionConfig.fromEnv();
  await serve(functionConfig, function.findLibrary('app'));
}
''');

    // bin/reflectable.build.yaml
    final build_yaml = AssetId(
      buildStep.inputId.package,
      path.join('bin', 'reflectable.build.yaml'),
    );
    await buildStep.writeAsString(build_yaml, '''
builders:
  reflectable|reflectable:
    build_to: cache
    defaults:
      generate_for:
        - bin/main.dart
    import: package:reflectable/reflectable_builder.dart
    builder_factories:
      - reflectableBuilder
    build_extensions:
      .dart:
        - .reflectable.dart
    auto_apply: root_package
''');
  }
}
