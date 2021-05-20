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

import 'dart:io';

/// Runs `dart/flutter pub upgrade` in every directory with a `pubspec.yaml`
/// file.
Future<void> main() async {
  final results = <String, int>{};

  Future<void> _work(Directory directory) async {
    for (var entry in directory.listSync()) {
      if (entry is File) {
        if (entry.path.endsWith('/pubspec.yaml')) {
          final parent = entry.parent.path;

          var exit = await _dartPub(parent);

          if (exit == 69) {
            exit = await _dartPub(parent, exe: 'flutter');
          }

          results[parent] = exit;
          break;
        }
      } else if (entry is Directory) {
        if (!entry.uri.pathSegments
            .where((element) => element.isNotEmpty)
            .last
            .startsWith('.')) {
          await _work(entry);
        }
      }
    }
  }

  await _work(Directory.current);

  print('Results:');
  print(results.entries.map((e) => '${e.key} - ${e.value}').join('\n'));
}

Future<int> _dartPub(String parent, {String exe = 'dart'}) async {
  final proc = await Process.start(
    exe,
    ['pub', 'upgrade'],
    workingDirectory: parent,
    mode: ProcessStartMode.inheritStdio,
  );
  final exit = await proc.exitCode;
  print('Exit code in $parent – $exit\n\n');
  return exit;
}
