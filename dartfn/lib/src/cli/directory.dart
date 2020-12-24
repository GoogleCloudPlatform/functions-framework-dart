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

import 'package:path/path.dart' as path;
import 'package:stagehand/stagehand.dart';

import '../printer.dart';

class DirectoryGeneratorTarget extends GeneratorTarget {
  final Printer printer;
  final io.Directory dir;

  DirectoryGeneratorTarget(this.printer, this.dir) {
    dir.createSync();
  }

  @override
  Future createFile(String filePath, List<int> contents) {
    var file = io.File(path.join(dir.path, filePath));

    printer.write('  ${file.path}');

    return file
        .create(recursive: true)
        .then((_) => file.writeAsBytes(contents));
  }
}

class TargetDirectoryNotEmptyError implements Exception {
  final String message;

  TargetDirectoryNotEmptyError(this.message);

  @override
  String toString() => message;
}

extension DirectoryHelpers on io.Directory {
  /// Returns true if the given directory does not contain non-symlinked,
  /// non-hidden subdirectories.
  Future<bool> isEmpty() async {
    var isHiddenDir = (dir) => path.basename(dir.path).startsWith('.');

    return list(followLinks: false)
        .where((entity) => entity is io.Directory)
        .where((entity) => !isHiddenDir(entity))
        .isEmpty;
  }

  String basename() {
    return path.basename(this.path);
  }
}
