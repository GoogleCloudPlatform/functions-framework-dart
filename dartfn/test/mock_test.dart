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

import 'dart:async';
import 'dart:convert';

import 'package:dartfn/src/generators.dart';
import 'package:dartfn/src/stagehand/stagehand.dart';
import 'package:test/test.dart';

void main() {
  for (var generator in generators) {
    test(generator.id, () => _testGenerator(getGenerator(generator.id)));
  }
}

Future _testGenerator(Generator generator) async {
  expect(generator.id, isNotNull);

  var target = MockTarget();

  // Assert that we can generate the template.
  await generator.generate('foo', target);

  // Run some basic validation on the generated results.
  expect(target.getFileContentsAsString('.gitignore'), isNotNull);
  expect(target.getFileContentsAsString('pubspec.yaml'), isNotNull);
}

class MockTarget extends GeneratorTarget {
  final Map<String, List<int>> _files = {};

  @override
  Future createFile(String path, List<int> contents) async {
    _files[path] = contents;
  }

  bool hasFile(String path) => _files.containsKey(path);

  String getFileContentsAsString(String path) {
    if (!hasFile(path)) return null;
    return utf8.decode(_files[path]);
  }
}
