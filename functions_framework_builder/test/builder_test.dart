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
const _functions = <FunctionEndpoint>{
  FunctionEndpoint.http(
    'handleGet',
    function_library.handleGet,
  ),
};
''',
    );
  });

  test('Populate the target param', () async {
    await _generateTest(
      r'''
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction(target: 'some function')
Response handleGet(Request request) => Response.ok('Hello, World!');
''',
      '''
$_outputHeader
const _functions = <FunctionEndpoint>{
  FunctionEndpoint.http(
    'some function',
    function_library.handleGet,
  ),
};
''',
    );
  });

  test('Valid shelf function shapes are supported', () async {
    final file = File('test/test_examples/valid_shelf_handlers.dart');

    final lines = [
      'syncFunction',
      'asyncFunction',
      'futureOrFunction',
      'extraParam',
      'optionalParam',
      'customResponse',
      'customResponseAsync',
      'customResponseFutureOr',
    ].map((e) => """
  FunctionEndpoint.http(
    '$e',
    function_library.$e,
  ),""").join('\n');
    await _generateTest(
      file.readAsStringSync(),
      '''
$_outputHeader
const _functions = <FunctionEndpoint>{
$lines
};
''',
    );
  });

  test('Valid CloudEvent function shapes are supported', () async {
    final file = File('test/test_examples/valid_cloud_event_handlers.dart');

    final lines = [
      'syncFunction',
      'asyncFunction',
      'futureOrFunction',
      'optionalParam',
      'objectParam',
    ].map((e) => """
  FunctionEndpoint.cloudEvent(
    '$e',
    function_library.$e,
  ),""").join('\n');
    await _generateTest(
      file.readAsStringSync(),
      '''
$_outputHeader
const _functions = <FunctionEndpoint>{
$lines
};
''',
    );
  });

  group('Valid custom type function shapes are supported', () {
    final inputContent =
        File('test/test_examples/valid_custom_type_handlers.dart')
            .readAsStringSync();

    test('void return type', () async {
      await _testItems(
          inputContent,
          [
            'syncFunction',
            'asyncFunction',
            'futureOrFunction',
            'extraParam',
            'optionalParam',
          ],
          (e, index) => """
  CustomTypeFunctionEndPoint.voidResult(
    '$e',
    function_library.$e,
    _factory$index,
  ),""",
          (index) => """
function_library.JsonType _factory$index(Object json) {
  if (json is Map<String, dynamic>) {
    return function_library.JsonType.fromJson(json);
  }
  throw BadRequestException(
    400,
    'The provided JSON is not the expected type `Map<String, dynamic>`.',
  );
}""");
    });

    test('void return type with context', () async {
      final newInputContent = inputContent
          .replaceAll(
            '(JsonType request) ',
            '(JsonType request, RequestContext context)',
          )
          .replaceAll(
            'int other',
            'RequestContext context, int other',
          );

      await _testItems(
          newInputContent,
          [
            'syncFunction',
            'asyncFunction',
            'futureOrFunction',
            'extraParam',
            'optionalParam',
          ],
          (e, index) => """
  CustomTypeWithContextFunctionEndPoint.voidResult(
    '$e',
    function_library.$e,
    _factory$index,
  ),""",
          (index) => """
function_library.JsonType _factory$index(Object json) {
  if (json is Map<String, dynamic>) {
    return function_library.JsonType.fromJson(json);
  }
  throw BadRequestException(
    400,
    'The provided JSON is not the expected type `Map<String, dynamic>`.',
  );
}""");
    });

    test('simple return type', () async {
      final newInputContent = inputContent
          .replaceAll('void ', 'int ')
          .replaceAll('<void>', '<int>');

      await _testItems(
          newInputContent,
          [
            'syncFunction',
            'asyncFunction',
            'futureOrFunction',
            'extraParam',
            'optionalParam',
          ],
          (e, index) => """
  CustomTypeFunctionEndPoint(
    '$e',
    function_library.$e,
    _factory$index,
  ),""",
          (index) => """
function_library.JsonType _factory$index(Object json) {
  if (json is Map<String, dynamic>) {
    return function_library.JsonType.fromJson(json);
  }
  throw BadRequestException(
    400,
    'The provided JSON is not the expected type `Map<String, dynamic>`.',
  );
}""");
    });

    test('JSON return type', () async {
      final newInputContent = inputContent
          .replaceAll('void ', 'int ')
          .replaceAll('<void>', '<int>');

      await _testItems(
          newInputContent,
          [
            'syncFunction',
            'asyncFunction',
            'futureOrFunction',
            'extraParam',
            'optionalParam',
          ],
          (e, index) => """
  CustomTypeFunctionEndPoint(
    '$e',
    function_library.$e,
    _factory$index,
  ),""",
          (index) => """
function_library.JsonType _factory$index(Object json) {
  if (json is Map<String, dynamic>) {
    return function_library.JsonType.fromJson(json);
  }
  throw BadRequestException(
    400,
    'The provided JSON is not the expected type `Map<String, dynamic>`.',
  );
}""");
    });

    test('complex return type', () async {
      final newInputContent = inputContent
          .replaceAll('void ', 'Map<String, List<JsonType>> ')
          .replaceAll('<void>', '<Map<String, List<JsonType>>>');

      await _testItems(
          newInputContent,
          [
            'syncFunction',
            'asyncFunction',
            'futureOrFunction',
            'extraParam',
            'optionalParam',
          ],
          (e, index) => """
  CustomTypeFunctionEndPoint(
    '$e',
    function_library.$e,
    _factory$index,
  ),""",
          (index) => """
function_library.JsonType _factory$index(Object json) {
  if (json is Map<String, dynamic>) {
    return function_library.JsonType.fromJson(json);
  }
  throw BadRequestException(
    400,
    'The provided JSON is not the expected type `Map<String, dynamic>`.',
  );
}""");
    });
  });

  group('Valid JSON type function shapes are supported', () {
    final inputContent =
        File('test/test_examples/valid_json_type_handlers.dart')
            .readAsStringSync();

    test('void return type', () async {
      await _testItems(
          inputContent,
          [
            'syncFunction',
            'asyncFunction',
            'futureOrFunction',
            'extraParam',
            'optionalParam',
          ],
          (e, index) => """
  CustomTypeFunctionEndPoint.voidResult(
    '$e',
    function_library.$e,
    _factory$index,
  ),""",
          (index) => """
num _factory$index(Object json) {
  if (json is num) {
    return json;
  }
  throw BadRequestException(
    400,
    'The provided JSON is not the expected type `num`.',
  );
}""");
    });

    test('simple return type', () async {
      final newInputContent = inputContent
          .replaceAll('void ', 'int ')
          .replaceAll('<void>', '<int>');
      await _testItems(
          newInputContent,
          [
            'syncFunction',
            'asyncFunction',
            'futureOrFunction',
            'extraParam',
            'optionalParam',
          ],
          (e, index) => """
  CustomTypeFunctionEndPoint(
    '$e',
    function_library.$e,
    _factory$index,
  ),""",
          (index) => """
num _factory$index(Object json) {
  if (json is num) {
    return json;
  }
  throw BadRequestException(
    400,
    'The provided JSON is not the expected type `num`.',
  );
}""");
    });

    test('complex return type', () async {
      final newInputContent = inputContent
          .replaceAll('void ', 'Map<String, List<bool>> ')
          .replaceAll('<void>', '<Map<String, List<bool>>>');

      await _testItems(
          newInputContent,
          [
            'syncFunction',
            'asyncFunction',
            'futureOrFunction',
            'extraParam',
            'optionalParam',
          ],
          (e, index) => """
  CustomTypeFunctionEndPoint(
    '$e',
    function_library.$e,
    _factory$index,
  ),""",
          (index) => """
num _factory$index(Object json) {
  if (json is num) {
    return json;
  }
  throw BadRequestException(
    400,
    'The provided JSON is not the expected type `num`.',
  );
}""");
    });

    test('void with context', () async {
      final newInputContent = inputContent
          .replaceAll(
            '(num request)',
            '(num request, RequestContext context)',
          )
          .replaceAll(
            'int other',
            'RequestContext context, int other',
          );

      await _testItems(
          newInputContent,
          [
            'syncFunction',
            'asyncFunction',
            'futureOrFunction',
            'extraParam',
            'optionalParam',
          ],
          (e, index) => """
  CustomTypeWithContextFunctionEndPoint.voidResult(
    '$e',
    function_library.$e,
    _factory$index,
  ),""",
          (index) => """
num _factory$index(Object json) {
  if (json is num) {
    return json;
  }
  throw BadRequestException(
    400,
    'The provided JSON is not the expected type `num`.',
  );
}""");
    });
  });

  test('duplicate target names fails', () async {
    await _generateThrows(
      r'''
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction()
Response function(Request request) => Response.ok('Hello, World!');

@CloudFunction(target: 'function')
Response function2(Request request) => Response.ok('Hello, World!');
''',
      isA<InvalidGenerationSourceError>().having(
        (e) => e.toString(),
        'toString()',
        '''
A function has already been annotated with target "function".
package:$_pkgName/functions.dart:8:10
  ╷
8 │ Response function2(Request request) => Response.ok('Hello, World!');
  │          ^^^^^^^^^
  ╵''',
      ),
    );
  });

  group('invalid function shapes are not allowed', () {
    final onlyFunctionMatcher =
        startsWith('Only top-level, public functions are supported.');
    final notCompatibleMatcher = startsWith(
      'Not compatible with a supported function shape:',
    );
    final invalidShapes = {
      //
      // Not functions
      //
      'class AClass{}': onlyFunctionMatcher,
      'int field = 5;': onlyFunctionMatcher,
      'int get getter => 5;': onlyFunctionMatcher,

      //
      // Double-annotated functions are not allowed
      //
      '@CloudFunction() Response function(Request request) => null;':
          startsWith(
        'Cannot be annotated with `CloudFunction` more than once.',
      ),

      //
      // pkg:shelf handlers
      //

      // Not enough params
      'Response handleGet() => null;': notCompatibleMatcher,
      // First param is not positional
      'Response handleGet({Request request}) => null;': notCompatibleMatcher,
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
      // Private functions do not work
      'Response _function(Request request) => null;': onlyFunctionMatcher,

      //
      // CloudEvent types handlers
      //

      // TODO: exclude return non-void return types?

      //
      // Custom and JSON event types
      //
      'Duration handleGet(DateTime request) => null;': notCompatibleMatcher,
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

Future<void> _testItems(
  String inputContent,
  List<String> functions,
  String Function(String entry, int index) entryFactory, [
  String Function(int index) factoryFactory,
]) async {
  var count = 0;
  final entries = functions.map((e) => entryFactory(e, count++)).join('\n');

  count = 0;
  final factories = functions.map((e) => factoryFactory(count++)).join('\n\n');

  await _generateTest(
    inputContent,
    '''
$_outputHeader
const _functions = <FunctionEndpoint>{
$entries
};

$factories
''',
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

import 'package:functions_framework/serve.dart';
import 'package:$_pkgName/functions.dart' as function_library;

Future<void> main(List<String> args) async {
  await serve(args, _functions);
}
''';
