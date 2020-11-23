// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

const defaultTimeout = Timeout(Duration(seconds: 3));

void main() {
  test('defaults', () async {
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
  }, timeout: defaultTimeout);
}
