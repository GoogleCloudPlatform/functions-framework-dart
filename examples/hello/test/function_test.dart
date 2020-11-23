// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

const defaultTimeout = Timeout(Duration(seconds: 3));

void main() {
  group('http function tests', () {
    test('defaults', () async {
      const defaultPort = '8080';
      final proc = await start();

      final response = await get('http://localhost:$defaultPort');
      expect(response.statusCode, 200);
      expect(response.body, 'Hello, World!');

      await finish(proc);
    }, timeout: defaultTimeout);

    test('good environment', () async {
      const port = '8888';
      final proc = await start(port: port, env: {
        'PORT': port,
      });

      final response = await get('http://localhost:$port');
      expect(response.statusCode, 200);
      expect(response.body, 'Hello, World!');

      await finish(proc);
    }, timeout: defaultTimeout);

    test('good options', () async {
      const port = '9000';
      final proc = await start(port: port, arguments: [
        '--port',
        port,
        '--target',
        'function',
        '--signature-type',
        'http'
      ], env: {
        // make sure args have precedence over environment
        'FUNCTION_TARGET': 'foo', // overridden by --target
        'FUNCTION_SIGNATURE_TYPE':
            'cloudevent', // overridden by --signature-type
      });

      final response = await get('http://localhost:$port');
      expect(response.statusCode, 200);
      expect(response.body, 'Hello, World!');

      await finish(proc);
    }, timeout: defaultTimeout);

    test('bad environment', () async {
      final proc =
          await start(shouldFail: true, env: {'FUNCTION_TARGET': 'bob'});

      await expectLater(
        proc.stderr,
        emitsThrough(
          'Bad state: There is no handler configured for '
          'FUNCTION_TARGET `bob`.',
        ),
      );

      await proc.shouldExit(255);
    }, timeout: defaultTimeout);

    test('bad options', () async {
      final proc = await start(shouldFail: true, arguments: [
        '--target',
        'bob',
      ]);

      await expectLater(
        proc.stderr,
        emitsThrough(
          'Bad state: There is no handler configured for '
          'FUNCTION_TARGET `bob`.',
        ),
      );

      await proc.shouldExit(255);
    }, timeout: defaultTimeout);

    test('bad options', () async {
      final proc =
          await start(shouldFail: true, arguments: ['--signature-type', 'foo']);

      await expectLater(
        proc.stderr,
        emitsThrough(
          'Unsupported operation: FUNCTION_SIGNATURE_TYPE environment variable '
          '"foo" is not a valid option (must be "http" or "cloudevent")',
        ),
      );

      await proc.shouldExit(255);
    }, timeout: defaultTimeout);
  });

  group('cloudevent function tests', () {});
}

Future<TestProcess> start(
    {bool shouldFail = false,
    String port = '8080',
    Map<String, String> env,
    Iterable<String> arguments = const <String>[]}) async {
  final args = ['bin/main.dart'] + List<String>.from(arguments);
  final proc = await TestProcess.start('dart', args, environment: env);

  if (!shouldFail) {
    await expectLater(
      proc.stdout,
      emitsThrough('App listening on :$port'),
    );
  }

  return proc;
}

Future<void> finish(final TestProcess proc) async {
  await expectLater(
    proc.stdout,
    emitsThrough(endsWith('GET     [200] /')),
  );
  proc.signal(ProcessSignal.sigterm);
  await proc.shouldExit(0);
  await expectLater(
    proc.stdout,
    emitsThrough('Got signal SIGTERM - closing'),
  );
}
