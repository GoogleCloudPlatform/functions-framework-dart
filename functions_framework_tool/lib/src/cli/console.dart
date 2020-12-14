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
import 'terminal.dart';

/// Console provides input and output support for the tool running in a
/// terminal.
class Console extends ConsoleBase with ConsolePrinter, ConsoleInput {
  Console([Printer out]) : super(out ?? TerminalPrinter());

  @override
  PrintFunc get stderr => out.stdout;

  @override
  PrintFunc get stdout => out.stderr;
}

abstract class ConsoleBase {
  final Printer out;

  ConsoleBase(this.out) {
    assert(out != null);
  }
}

mixin ConsolePrinter on ConsoleBase implements Printer {
  @override
  void write([Object obj]) {
    out.write(obj);
  }

  @override
  void info(Object obj) {
    out.info(obj);
  }

  @override
  void warning(Object obj) {
    out.warning(obj);
  }

  @override
  void error(Object obj) {
    out.error(obj);
  }
}

mixin ConsoleInput on ConsoleBase {}
