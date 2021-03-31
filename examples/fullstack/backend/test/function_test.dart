import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

import 'package:backend/functions.dart';

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

    final response = await post(
      Uri.parse('http://localhost:8080'),
      headers: headers,
      body: body,
    );
    expect(response.statusCode, 200);

    final data = json.decode(response.body) as Map<String, dynamic>;
    final actualResponse = GreetingResponse.fromJson(data);

    // Use any salutation from the list of salutations
    final expectedResponse =
        GreetingResponse(salutation: salutations[0], name: 'World');

    expect(salutations, contains(actualResponse.salutation));
    expect(actualResponse.name, expectedResponse.name);

    proc.signal(ProcessSignal.sigterm);
    await proc.shouldExit(0);

    await expectLater(
      proc.stdout,
      emitsThrough('Received signal SIGTERM - closing'),
    );
  }, timeout: defaultTimeout);
}
