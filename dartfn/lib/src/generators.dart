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

import 'generators/cloudevent.dart';
import 'generators/helloworld.dart';
import 'generators/json.dart';
import 'stagehand/stagehand.dart';

/// A sorted list of Dart Functions Framework project generators.
final List<Generator> generators = [
  HelloWorldGenerator(),
  JsonFunctionGenerator(),
  CloudEventFunctionGenerator(),
]..sort();

Generator getGenerator(String id) => generators.singleWhere((g) => g.id == id);
