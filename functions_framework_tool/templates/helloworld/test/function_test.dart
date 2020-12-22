import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

const defaultTimeout = Timeout(Duration(seconds: 3));

void main() {
  test('defaults', () async {
    final proc = await TestProcess.start('dart', ['bin/server.dart']);

    await expectLater(
      proc.stdout,
      emitsThrough('Listening on :8080'),
    );

    final response = await get('http://localhost:8080');
    expect(response.statusCode, 200);
    expect(response.body, 'Hello, World!');

    proc.signal(ProcessSignal.sigterm);
    await proc.shouldExit(0);

    await expectLater(
      proc.stdout,
      emitsThrough('Received signal SIGTERM - closing'),
    );
  }, timeout: defaultTimeout);
}
