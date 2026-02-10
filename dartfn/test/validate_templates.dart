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

// This is explicitly not named with _test.dart extension so it is not run as
// part of the normal test process
@TestOn('vm')
library;

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dartfn/src/generators.dart';
import 'package:dartfn/src/stagehand/stagehand.dart' as stagehand;
import 'package:grinder/grinder.dart' hide fail;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;

const _pubspecOrder = [
  'name',
  'description',
  'version',
  'homepage',
  'environment',
  'dependencies',
  'dev_dependencies',
];

final List<RegExp> _pubspecOrderRegexps =
    _pubspecOrder.map((s) => RegExp('^(# *)?$s:', multiLine: true)).toList();

final String _expectedGitIgnore = _getMetaTemplateFile('.gitignore');
final String _expectedAnalysisOptions = _getMetaTemplateFile(
  'templates/analysis_options.yaml',
);

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('stagehand.test.');

    addTearDown(() => dir.delete(recursive: true));
  });

  test(
    'Meta-template .gitignore exists',
    () => expect(_expectedGitIgnore, isNotEmpty),
  );

  test(
    'Meta-template analysis_options.yaml exists',
    () => expect(_expectedAnalysisOptions, isNotEmpty),
  );

  test('Validate pkg/stagehand pubspec', () {
    final pubspecContent =
        File(path.join(path.current, 'pubspec.yaml')).readAsStringSync();
    _validatePubspec(pubspecContent);
  });

  group('generator', () {
    for (var generator in generators) {
      test(generator.id, () {
        _testGenerator(generator, dir);
      });
    }
  });
}

void _testGenerator(stagehand.Generator generator, Directory tempDir) {
  Dart.run(
    path.join(path.current, 'bin/dartfn.dart'),
    arguments: ['--mock-analytics', generator.id],
    runOptions: RunOptions(workingDirectory: tempDir.path),
  );

  final pubspecPath = path.join(tempDir.path, 'pubspec.yaml');
  final pubspecFile = File(pubspecPath);
  final pubspecContentString = pubspecFile.readAsStringSync();
  final pubspecContent = yaml.loadYaml(pubspecContentString) as yaml.YamlMap;

  final analysisOptionsPath = path.join(tempDir.path, 'analysis_options.yaml');
  final analysisOptionsFile = File(analysisOptionsPath);
  expect(
    analysisOptionsFile.readAsStringSync(),
    _expectedAnalysisOptions,
    reason: 'All analysis_options.yaml files should be identical.',
  );

  if (!pubspecFile.existsSync()) {
    fail('A pubspec must be defined!');
  }

  Pub.get(runOptions: RunOptions(workingDirectory: tempDir.path));

  String? filePath = path.join(tempDir.path, generator.entrypoint!.path);

  if (path.extension(filePath) != '.dart' ||
      !FileSystemEntity.isFileSync(filePath)) {
    final parent = Directory(path.dirname(filePath));

    final file = _listSync(
      parent,
    ).firstWhereOrNull((f) => f.path.endsWith('.dart'));

    if (file == null) {
      filePath = null;
    } else {
      filePath = file.path;
    }
  }

  // Run the analyzer.
  if (filePath != null) {
    final cwd = Directory.current;
    try {
      // TODO: Extend Analyzer.analyze to support .packages files.
      Directory.current = tempDir.path;
      Analyzer.analyze(filePath, fatalWarnings: true);
    } finally {
      Directory.current = cwd;
    }
  }

  //
  // validate pubspec values
  //
  // TODO: Update this to handle the pubspec file for flutter_web.
  //_validatePubspec(pubspecContentString);

  expect(pubspecContent, containsPair('name', 'stagehand'));
  expect(pubspecContent, containsPair('description', isNotEmpty));

  expect(
    pubspecContent,
    containsPair('environment', {'sdk': '>=2.10.0 <3.0.0'}),
  );

  // Run package tests, if `test` is included.
  final devDeps = pubspecContent['dev_dependencies'] as Map?;
  if (devDeps != null) {
    if (devDeps.containsKey('test')) {
      if (devDeps.containsKey('build_test')) {
        // Use build_runner test – and try both VM and Chrome
        Pub.run(
          'build_runner',
          arguments: ['test', '--', '-p', 'vm,chrome'],
          runOptions: RunOptions(workingDirectory: tempDir.path),
        );
      } else {
        Pub.run('test', runOptions: RunOptions(workingDirectory: tempDir.path));
      }
    }
  }
}

void _validatePubspec(String pubspecContentString) {
  // Note: the regex will match lines even if they are commented out
  final orders =
      _pubspecOrderRegexps
          .map((regexp) => pubspecContentString.indexOf(regexp))
          .toList();

  // On failure, you'll just see numbers – but the `reason` will help understand
  // which order things should go in.
  expect(
    orders,
    orderedEquals(orders.toList()..sort()),
    reason:
        'Top-level keys in the pubspec were not in the expected order: '
        "${_pubspecOrder.join(',')}",
  );
}

/// Return the list of children for the given directory. This list is normalized
/// (by sorting on the file path) in order to prevent large merge diffs in the
/// generated template data files.
List<FileSystemEntity> _listSync(
  Directory dir, {
  bool recursive = false,
  bool followLinks = true,
}) =>
    dir.listSync(recursive: recursive, followLinks: followLinks)
      ..sort((entity1, entity2) => entity1.path.compareTo(entity2.path));

// Gets the named meta-template file if available, returns '' otherwise.
String _getMetaTemplateFile(String fileName) {
  try {
    return File(path.join(path.current, fileName)).readAsStringSync();
  } on FileSystemException catch (_) {
    return '';
  }
}
