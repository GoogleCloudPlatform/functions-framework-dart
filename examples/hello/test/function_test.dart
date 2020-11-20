import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  test('defaults', () async {
    const port = '8080';

    final proc = await TestProcess.start('dart', ['bin/main.dart']);

    await expectLater(
      proc.stdout,
      emitsThrough('App listening on :$port'),
    );

    final response = await get('http://localhost:$port');

    expect(response.statusCode, 200);
    expect(response.body, 'Hello, World!');

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
  }, timeout: const Timeout(Duration(seconds: 2)));

  test('good environment', () async {
    const port = '8888';

    final proc = await TestProcess.start('dart', [
      'bin/main.dart'
    ], environment: {
      'PORT': port,
    });

    await expectLater(
      proc.stdout,
      emitsThrough('App listening on :$port'),
    );

    final response = await get('http://localhost:$port');

    expect(response.statusCode, 200);
    expect(response.body, 'Hello, World!');

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
  }, timeout: const Timeout(Duration(seconds: 2)));

  test('good options', () async {
    const port = '9000';

    final proc = await TestProcess.start('dart', [
      'bin/main.dart',
      '--port',
      '$port',
      '--target',
      'function',
      '--signature-type',
      'http'
    ], environment: {
      // make sure args have precedence over environment
      'FUNCTION_TARGET': 'foo', // overridden by --target
      'FUNCTION_SIGNATURE_TYPE': 'cloudevent', // overridden by --signature-type
    });

    await expectLater(
      proc.stdout,
      emitsThrough('App listening on :$port'),
    );

    final response = await get('http://localhost:$port');

    expect(response.statusCode, 200);
    expect(response.body, 'Hello, World!');

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
  }, timeout: const Timeout(Duration(seconds: 2)));

  test('bad environment', () async {
    final proc = await TestProcess.start(
      'dart',
      ['bin/main.dart'],
      environment: {'FUNCTION_TARGET': 'bob'},
    );

    await expectLater(
      proc.stderr,
      emitsThrough(
        'Bad state: There is no handler configured for FUNCTION_TARGET `bob`.',
      ),
    );

    await proc.shouldExit(255);
  }, timeout: const Timeout(Duration(seconds: 2)));

  test('bad options', () async {
    final proc = await TestProcess.start('dart', [
      'bin/main.dart',
      '--target',
      'bob',
    ]);

    await expectLater(
      proc.stderr,
      emitsThrough(
        'Bad state: There is no handler configured for FUNCTION_TARGET `bob`.',
      ),
    );

    await proc.shouldExit(255);
  }, timeout: const Timeout(Duration(seconds: 2)));

  test('bad options', () async {
    final proc = await TestProcess.start('dart', [
      'bin/main.dart',
      '--signature-type',
      'foo'
    ]);

    await expectLater(
      proc.stderr,
      emitsThrough(
        'Unsupported operation: FUNCTION_SIGNATURE_TYPE environment variable '
        '"foo" is not a valid option (must be "http" or "cloudevent")',
      ),
    );

    await proc.shouldExit(255);
  }, timeout: const Timeout(Duration(seconds: 2)));
}
