import 'dart:convert';
import 'dart:io';

import 'package:__projectName__/functions.dart';
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

    const body = '''
    {
      "name": "World"
    }''';

    const headers = {'content-type': 'application/json'};

    final response =
        await post('http://localhost:8080', headers: headers, body: body);
    expect(response.statusCode, 200);

    final data = json.decode(response.body) as Map<String, dynamic>;
    final actualResponse = GreetingResponse.fromJson(data);

    final expectedResponse =
        GreetingResponse(salutation: 'Hello', name: 'World');

    expect(actualResponse, expectedResponse);

    proc.signal(ProcessSignal.sigterm);
    await proc.shouldExit(0);

    await expectLater(
      proc.stdout,
      emitsThrough('Received signal SIGTERM - closing'),
    );
  }, timeout: defaultTimeout);
}
