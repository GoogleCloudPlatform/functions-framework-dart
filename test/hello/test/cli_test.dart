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

@Timeout(Duration(seconds: 3))
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:io/io.dart';
import 'package:test/test.dart';

import 'src/test_utils.dart';

void main() {
  test('defaults', () async {
    final proc = await startServerTest();

    final response = await get('http://localhost:$defaultPort');
    expect(response.statusCode, 200);
    expect(response.body, 'Hello, World!');

    await finishServerTest(proc);
  });

  test('SIGINT also terminates the server', () async {
    final proc = await startServerTest();

    final response = await get('http://localhost:$defaultPort');
    expect(response.statusCode, 200);
    expect(response.body, 'Hello, World!');

    await finishServerTest(proc, signal: ProcessSignal.sigint);
  });

  test('good options', () async {
    const port = 9000;
    final proc = await startServerTest(
      expectedListeningPort: port,
      arguments: [
        '--port',
        port.toString(),
        '--target',
        'function',
        '--signature-type',
        'http'
      ],
      env: {
        // make sure args have precedence over environment
        'FUNCTION_TARGET': 'foo', // overridden by --target
        'FUNCTION_SIGNATURE_TYPE':
            'cloudevent', // overridden by --signature-type
      },
    );

    final response = await get('http://localhost:$port');
    expect(response.statusCode, 200);
    expect(response.body, 'Hello, World!');

    await finishServerTest(proc);
  });

  group('environment', () {
    test('good environment', () async {
      const port = 8888;
      final proc = await startServerTest(expectedListeningPort: port, env: {
        'PORT': port.toString(),
      });

      final response = await get('http://localhost:$port');
      expect(response.statusCode, 200);
      expect(response.body, 'Hello, World!');

      await finishServerTest(proc);
    });

    test('bad FUNCTION_TARGET', () async {
      final proc = await startServerTest(shouldFail: true, env: {
        'FUNCTION_TARGET': 'bob',
      });

      await expectLater(
        proc.stderr,
        emitsThrough(
          'There is no handler configured for FUNCTION_TARGET `bob`.',
        ),
      );

      await proc.shouldExit(ExitCode.usage.code);
    });

    test('bad FUNCTION_SIGNATURE_TYPE', () async {
      final proc = await startServerTest(shouldFail: true, env: {
        'FUNCTION_SIGNATURE_TYPE': 'bob',
      });

      await expectLater(
        proc.stderr,
        emitsThrough(
          'FUNCTION_SIGNATURE_TYPE environment variable "bob" is not a valid '
          'option (must be "http" or "cloudevent")',
        ),
      );

      await proc.shouldExit(ExitCode.usage.code);
    });

    test('bad PORT', () async {
      final proc = await startServerTest(shouldFail: true, env: {
        'PORT': 'bob',
      });

      await expectLater(
        proc.stderr,
        emitsThrough(
          'Bad value for environment variable "PORT" – "bob" – '
          'Invalid radix-10 number.',
        ),
      );

      await proc.shouldExit(ExitCode.usage.code);
    });
  });

  group('command line', () {
    test('unsupported option', () async {
      final proc = await startServerTest(
        shouldFail: true,
        arguments: [
          '--bob',
        ],
      );

      await expectLater(
        proc.stderr,
        emitsInOrder([
          'Could not find an option named "bob".',
          ...LineSplitter.split(_usage),
        ]),
      );

      await proc.shouldExit(ExitCode.usage.code);
    });

    test('bad target', () async {
      final proc = await startServerTest(
        shouldFail: true,
        arguments: [
          '--target',
          'bob',
        ],
      );

      await expectLater(
        proc.stderr,
        emitsThrough(
          'There is no handler configured for FUNCTION_TARGET `bob`.',
        ),
      );

      await proc.shouldExit(ExitCode.usage.code);
    });

    test('bad signature', () async {
      final proc = await startServerTest(
        shouldFail: true,
        arguments: ['--signature-type', 'foo'],
      );

      await expectLater(
        proc.stderr,
        emitsInOrder([
          '"foo" is not an allowed value for option "signature-type".',
          ...LineSplitter.split(_usage),
        ]),
      );

      await proc.shouldExit(ExitCode.usage.code);
    });

    test('bad port', () async {
      final proc = await startServerTest(
        shouldFail: true,
        arguments: ['--port', 'foo'],
      );

      await expectLater(
        proc.stderr,
        emitsInOrder([
          'Bad value for "port" – "foo" – Invalid radix-10 number.',
          ...LineSplitter.split(_usage),
        ]),
      );

      await proc.shouldExit(ExitCode.usage.code);
    });
  });
}

const _usage = r'''
--port              The port on which the Functions Framework listens for
                    requests.
                    Overrides the PORT environment variable.
--target            The name of the exported function to be invoked in response
                    to requests.
                    Overrides the FUNCTION_TARGET environment variable.
--signature-type    The signature used when writing your function. Controls
                    unmarshalling rules and determines which arguments are used
                    to invoke your function.
                    Overrides the FUNCTION_SIGNATURE_TYPE environment variable.
                    [http, cloudevent]''';
