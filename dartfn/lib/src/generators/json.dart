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

import '../stagehand/common.dart' as common;

part 'json.g.dart';

/// A generator for a pub library.
class JsonFunctionGenerator extends common.DefaultGenerator {
  JsonFunctionGenerator()
      : super('json', 'Dart Package',
            'A sample Functions Framework project for handling JSON.',
            categories: const ['dart']) {
    for (var file in common.decodeConcatenatedData(_data)) {
      addTemplateFile(file);
    }

    setEntrypoint(getFile('bin/server.dart'));
  }
}
