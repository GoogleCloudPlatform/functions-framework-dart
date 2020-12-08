// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:functions_framework_builder/builder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'test_package_asset_reader.dart';

void main() {
  tearDown(() {
    // Increment this after each test so the next test has it's own package
    _pkgCacheCount++;
  });

  test('Simple Generator test', () async {
    await _generateTest(
      r'''
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction()
Response handleGet(Request request) => Response.ok('Hello, World!');
''',
      '''
$_outputHeader
const _functions = <String, Handler>{
  'function': function_library.handleGet,
};
''',
    );
  });

  test('Populate the target param', () async {
    await _generateTest(
      r'''
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction('some function')
Response handleGet(Request request) => Response.ok('Hello, World!');
''',
      '''
$_outputHeader
const _functions = <String, Handler>{
  'some function': function_library.handleGet,
};
''',
    );
  });

  test('All valid function shapes are supported', () async {
    final file = File('test/test_examples/all_valid_shapes.dart');
    await _generateTest(
      file.readAsStringSync(),
      '''
$_outputHeader
const _functions = <String, Handler>{
  'sync': function_library.handleGet,
  'async': function_library.handleGet2,
  'futureOr': function_library.handleGet3,
  'extra params': function_library.handleGet4,
  'optional positional': function_library.handleGet5,
};
''',
    );
  });

  test('duplicate target names fails', () async {
    await _generateThrows(
      r'''
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction()
Response handleGet(Request request) => Response.ok('Hello, World!');

@CloudFunction()
Response handleGet(Request request) => Response.ok('Hello, World!');
''',
      isA<InvalidGenerationSourceError>().having(
        (e) => e.toString(),
        'toString()',
        '''
A function has already been annotated with target "function".
package:$_pkgName/functions.dart:8:10
  ╷
8 │ Response handleGet(Request request) => Response.ok('Hello, World!');
  │          ^^^^^^^^^
  ╵''',
      ),
    );
  });

  group('invalid function shapes are not allowed', () {
    final onlyFunctionMatcher =
        startsWith('Only top-level functions are supported.');
    final notCompatibleMatcher = startsWith(
      'Not compatible with package:shelf Handler '
      '`FutureOr<Response> Function(Request)`.',
    );
    final invalidShapes = {
      'class AClass{}': onlyFunctionMatcher,
      'int field = 5;': onlyFunctionMatcher,
      'int get getter => 5;': onlyFunctionMatcher,
      // Not enough params
      'Response handleGet() => null;': notCompatibleMatcher,
      // First param is not positional
      'Response handleGet({Request reques}) => null;': notCompatibleMatcher,
      // Too many required params
      'Response handleGet(Request request, int other) => null;':
          notCompatibleMatcher,
      // Param is wrong type
      'Response handleGet(int request) => null;': notCompatibleMatcher,
      // Return type is wrong
      'int handleGet(Request request) => null;': notCompatibleMatcher,
      // Return type is wrong
      'Future<int> handleGet(Request request) => null;': notCompatibleMatcher,
      // Return type is wrong
      'FutureOr<int> handleGet(Request request) => null;': notCompatibleMatcher,
    };

    for (var shape in invalidShapes.entries) {
      test('"${shape.key}"', () async {
        await _generateThrows(
          '''
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction()
${shape.key}
''',
          isA<InvalidGenerationSourceError>().having(
            (e) => e.toString(),
            'toString()',
            shape.value,
          ),
        );
      });
    }
  });
}

Future<void> _generateThrows(String inputLibrary, Object matcher) async {
  await expectLater(
    () => _generateTest(inputLibrary, null, validateLog: false),
    throwsA(matcher),
  );
}

Future<void> _generateTest(
  String inputLibrary,
  String expectedContent, {
  bool validateLog = true,
}) async {
  final srcs = {'$_pkgName|lib/functions.dart': inputLibrary};

  await testBuilder(
    functionsFrameworkBuilder(),
    srcs,
    generateFor: {
      ...srcs.keys,
      '$_pkgName|\$package\$',
    },
    outputs: expectedContent == null
        ? null
        : {
            '$_pkgName|bin/server.dart': decodedMatches(expectedContent),
          },
    onLog: (log) {
      if (!validateLog) {
        return;
      }
      if (_ignoredLogMessages.any(log.message.contains)) {
        return;
      }
      addTearDown(() {
        var output = 'Unexpected log message: "${log.message}"';
        if ((log.message == null || log.message.isEmpty) && log.error != null) {
          output = '$output (${log.error})';
        }
        fail(output);
      });
    },
    reader: await TestPackageAssetReader.currentIsolate(),
  );
}

const _ignoredLogMessages = {
  'Generating SDK summary',
  'Your current `analyzer` version may not fully support your current '
      'SDK version.',
};

// Ensure every test gets its own unique package name
String get _pkgName => 'pkg$_pkgCacheCount';
int _pkgCacheCount = 1;

String get _outputHeader => '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'package:functions_framework/serve.dart';
import 'package:shelf/shelf.dart';

import 'package:$_pkgName/functions.dart' as function_library;

Future<void> main(List<String> args) async {
  await serve(args, _functions);
}
''';
