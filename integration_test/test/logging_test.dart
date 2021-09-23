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

import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

import 'src/test_utils.dart';

Future<TestProcess> _startServerTest() => startServerTest(
      arguments: [
        '--target',
        'loggingHandler',
      ],
      expectedListeningPort: 0,
    );

void main() {
  test('test all log severities', () async {
    final proc = await _startServerTest();

    final requestUrl = 'http://localhost:$autoPort/';
    final response = await get(requestUrl);
    expect(response.statusCode, 200);
    expect(response.body, '');

    await finishServerTest(
      proc,
      requestOutput: emitsInOrder(
        [
          'default',
          'DEBUG: debug',
          'INFO: info',
          'NOTICE: notice',
          'WARNING: warning',
          'ERROR: error',
          'CRITICAL: critical',
          'ALERT: alert',
          'EMERGENCY: emergency',
          endsWith('GET     [200] /'),
        ],
      ),
    );
  });
}
