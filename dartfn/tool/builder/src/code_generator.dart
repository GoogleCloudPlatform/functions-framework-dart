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
import 'dart:convert';
import 'dart:math' as math;

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

const _allowedDotFiles = {'.gitignore'};
final RegExp _binaryFileTypes = RegExp(
  r'\.(jpe?g|png|gif|ico|svg|ttf|eot|woff|woff2)$',
  caseSensitive: false,
);
const _excludedRootFiles = {'build', 'pubspec.lock', 'mono_pkg.yaml'};

class DataGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    if (!p.isWithin('lib/src/generators', buildStep.inputId.path)) {
      return null;
    }

    final name = p
        .basenameWithoutExtension(buildStep.inputId.path)
        .replaceAll('_', '-');

    final filteredAssets =
        await buildStep.findAssets(Glob('templates/$name/**')).where((asset) {
            final rootSegment = asset.pathSegments[2];

            if (_excludedRootFiles.contains(rootSegment)) {
              return false;
            }

            if (_allowedDotFiles.contains(rootSegment)) {
              return true;
            }

            return !rootSegment.startsWith('.');
          }).toList()
          ..sort();

    final items = await _getLines(filteredAssets, buildStep)
        .map((item) {
          if (item.contains('\n')) {
            return "'''\n$item'''";
          }
          return "'$item'";
        })
        .join(',');

    return 'const _data = <String>[$items];';
  }
}

Stream<String> _getLines(List<AssetId> ids, AssetReader reader) async* {
  for (var id in ids) {
    yield p.url.joinAll(id.pathSegments.skip(2));
    yield _binaryFileTypes.hasMatch(p.basename(id.path)) ? 'binary' : 'text';

    if (id.pathSegments.last == 'analysis_options.yaml') {
      var content = await reader.readAsString(id);
      if (content.contains(_lintFix)) {
        content = content.replaceAll(_lintFix, '');
        yield _base64encode(utf8.encode(content));
      } else {
        throw StateError('Expected `${id.path}` to contain:\n$_lintFix');
      }
    } else {
      yield _base64encode(await reader.readAsBytes(id));
    }
  }
}

const _lintFix = r'''

# This is here to fix CI analysis. Will be removed at generation.
# Search source code for details
linter:
  rules:
    file_names: false
''';

String _base64encode(List<int> bytes) {
  final encoded = base64.encode(bytes);

  //
  // Logic to cut lines into 76-character chunks
  // – makes for prettier source code
  //
  final lines = <String>[];
  var index = 0;

  while (index < encoded.length) {
    final line = encoded.substring(index, math.min(index + 76, encoded.length));
    lines.add(line);
    index += line.length;
  }

  return lines.join('\n');
}
