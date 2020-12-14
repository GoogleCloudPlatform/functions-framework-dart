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

import 'dart:io' as io;

import 'package:stagehand/stagehand.dart';

import 'console.dart';

class Context {
  final AppInfo app;
  final Console console;
  final GeneratorConfig generator;

  Context({this.app, this.console, this.generator});
}

class AppInfo {
  final String name;
  final String version;

  AppInfo(this.name, this.version);
}

class GeneratorConfig {
  final List<Generator> generators;
  final io.Directory cwd;
  final GeneratorTarget target;

  GeneratorConfig({this.generators, this.cwd, this.target});
}
