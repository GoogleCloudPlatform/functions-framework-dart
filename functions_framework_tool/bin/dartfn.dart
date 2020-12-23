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

import 'package:io/io.dart' show ExitCode;

import 'package:args/command_runner.dart';
import 'package:dartfn/functions_framework_tool.dart' as tool;
import 'package:dartfn/src/cli/app.dart' as cli;

// Initialize the CLI app with a list of generators and a terminal printer.
// Process args and/or execute a subcommand. Always exit immediately when the
// command returns, regardless of any pending async I/O tasks (such as fetching
// logs or updating analytics); don't let CLI hang in an unexpected way from the
// user's perspective before returning to the shell prompt.
// Normal (expected) errors are handled by the CLI app and displayed to the
// user; only print errors and a stacktrace for problems indicating there is
// something wrong with the app itself.
FutureOr<int> main(List<String> args) async {
  final app = cli.App(tool.generators, cli.TerminalPrinter());

  try {
    await app.run(args);
    return io.exitCode = 0;
  } catch (e, st) {
    if (e is UsageException) {
      return io.exitCode = ExitCode.usage.code;
    } else {
      print('Unexpected error: $e\n$st');
      return io.exitCode = ExitCode.software.code;
    }
  }
}
