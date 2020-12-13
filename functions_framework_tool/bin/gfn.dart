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

import 'package:functions_framework_tool/functions_framework_tool.dart';
import 'package:functions_framework_tool/src/cli/cli.dart';

void main(List<String> args) {
  var app = CliApp(generators, CliLogger());

  try {
    try {
      app.process(args).catchError((Object e, StackTrace st) {
        if (e is ArgError) {
          // These errors are expected errors errors, already displayed.
          io.exit(1);
        } else {
          print('Unexpected error: $e\n$st');
          io.exit(1);
        }
      }).whenComplete(() {
        // Always exit immediately as soon as command completes, regardless of
        // pending I/O tasks (such as fetching logs or updating analytics);
        // don't let CLI hang in an unexpected way from the user's perspective.
        io.exit(0);
      });
    } catch (e, s) {
      print(s);
    }
  } catch (e, st) {
    print('Unexpected error: $e\n$st');
  }
}
