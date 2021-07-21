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

typedef PrintFunc = void Function(Object obj);

/// Printer provides a basic interface for user-facing tool output & logs.
class Printer {
  final PrintFunc stdout;
  final PrintFunc stderr;

  Printer([PrintFunc? stdout, PrintFunc? stderr])
      : stdout = stdout ?? print,
        stderr = stderr ?? stdout ?? print {
    assert(stdout != null);
    assert(stderr != null);
  }

  Printer.fromPrinter(Printer printer)
      : stdout = printer.stdout,
        stderr = printer.stderr;

  void write([Object? obj]) {
    stdout(obj ?? '');
  }

  void info(Object obj) {
    stdout(obj);
  }

  void warning(Object obj) {
    stdout(obj);
  }

  void error(Object obj) {
    stderr(obj);
  }
}
