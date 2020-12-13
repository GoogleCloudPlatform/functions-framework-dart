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

/// Stagehand is a Dart project generator.
///
/// Stagehand helps you get your Dart projects set up and ready for the big
/// show.
/// It is a Dart project scaffolding generator, inspired by tools like Web
/// Starter Kit and Yeoman.
///
/// It can be used as a command-line application, or as a regular Dart library
/// composed it a larger development tool. To use as a command-line app, run:
///
/// ```console
/// > pub global run stagehand
/// ```
///
/// to see a list of all app types you can create, and:
///
/// ```console
/// > mkdir foobar
/// > cd foobar
/// > pub global run stagehand webapp
/// ```
///
/// to create a new instance of the `webapp` template in a `foobar` directory.

// Export so functions framework project generators can be used by other tools.
export 'src/generators/generators.dart';
export 'src/version.dart';
