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

import 'package:dartfn/src/stagehand/common.dart';
import 'package:test/test.dart';

void main() {
  group('common', () {
    test('normalizeProjectName', () {
      expect(normalizeProjectName('foo.dart'), 'foo');
      expect(normalizeProjectName('foo-bar'), 'foo_bar');
    });

    group('substituteVars', () {
      test('simple', () {
        _expect('foo __bar__ baz', {'bar': 'baz'}, 'foo baz baz');
      });

      test('nosub', () {
        _expect('foo __bar__ baz', {'aaa': 'bbb'}, 'foo __bar__ baz');
      });

      test('matching input', () {
        _expect('foo __bar__ baz', {'bar': '__baz__', 'baz': 'foo'},
            'foo __baz__ baz');
      });

      test('vars must be alpha + numeric', () {
        expect(() => substituteVars('str', {'with space': 'noop'}),
            throwsArgumentError);
        expect(() => substituteVars('str', {'with!symbols': 'noop'}),
            throwsArgumentError);
        expect(() => substituteVars('str', {'with1numbers': 'noop'}),
            throwsArgumentError);
        expect(() => substituteVars('str', {'with_under': 'noop'}),
            throwsArgumentError);
      });
    });
  });
}

void _expect(String original, Map<String, String> vars, String result) {
  expect(substituteVars(original, vars), result);
}
