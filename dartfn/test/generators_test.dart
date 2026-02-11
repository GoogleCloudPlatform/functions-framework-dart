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

import 'package:dartfn/src/generators.dart';
import 'package:dartfn/src/stagehand/stagehand.dart';
import 'package:test/test.dart';

void main() {
  group('generators', () {
    for (var generator in generators) {
      test(generator.id, () => validate(getGenerator(generator.id)));
    }
  });
}

void validate(Generator generator) {
  expect(generator.id, isNot(contains(' ')));
  expect(generator.description, endsWith('.'));
  expect(generator.entrypoint, isNotNull);
  expect(generator.getInstallInstructions(), isNotNull);
  final pubspec = generator.getFile('pubspec.yaml');
  expect(pubspec.content, contains('__projectName__'));
  final functions = generator.getFile('lib/functions.dart');
  expect(functions.content, contains('__projectName__'));
}
