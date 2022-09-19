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

import '../printer.dart';

/// TerminalPrinter is a printer for writing decorated/colorized output to a
/// terminal for the CLI.
class TerminalPrinter extends Printer {
  TerminalPrinter(
      [PrintFunc super.stdout = print, PrintFunc super.stderr = print]);

  TerminalPrinter.fromPrinter(super.printer) : super.fromPrinter();

  @override
  void write([Object? obj]) {
    stdout(obj ?? '');
  }

  @override
  void info(Object obj) {
    stdout(obj);
  }

  @override
  void warning(Object obj) {
    stdout('Warning! $obj');
  }

  @override
  void error(Object obj) {
    if (obj is Exception) {
      try {
        obj = (obj as dynamic).message;
      } on NoSuchMethodError {
        // ok
      }
    }
    stderr('Error: $obj');
  }
}
