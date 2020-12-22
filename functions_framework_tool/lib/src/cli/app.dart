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
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:stagehand/stagehand.dart';

import '../printer.dart';
import '../version.dart';
import 'command/generate.dart';
import 'command/version.dart';
import 'console.dart';
import 'command.dart';

export 'terminal.dart' show TerminalPrinter;

const String appName = 'fn';
const String appDescription =
    'fn is a tool for managing Dart Functions-as-a-Service (FaaS) projects.';

/// App is a CLI tool for running in a user's terminal.
class App extends Console {
  CommandContext _context;
  CommandRunner _runner;

  App(List<Generator> generators, [Printer out, GeneratorTarget target])
      : assert(generators != null),
        super(out) {
    generators.sort();

    _context = CommandContext(
        app: AppInfo(appName, packageVersion),
        console: this,
        generator: GeneratorConfig(
            generators: generators, cwd: io.Directory.current, target: target));

    _runner = CommandRunner(appName, appDescription)
      ..addCommand(GenerateCommand(context))
      ..addCommand(VersionCommand(context));
  }

  CommandContext get context => _context;

  Future run(List<String> args) async {
    try {
      await _runner.run(args);
    } catch (e, st) {
      // UsageException comes from the CommandRunner arg parser as well as the
      // individual subcommand implementations. Don't need to print stacktrace.
      // Must force toString() on e or will only print message (without usage).
      if (e is UsageException) {
        return Future.sync(() => context.console.error(e.toString()));
      } else {
        return Future.error(e, st);
      }
    }
  }
}
