import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  test('good environment', () async {
    final proc = await TestProcess.start('dart', ['bin/main.dart']);

    await expectLater(
      proc.stdout,
      emitsThrough('App listening on :8080'),
    );

    final response = await get('http://localhost:8080');

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
}
