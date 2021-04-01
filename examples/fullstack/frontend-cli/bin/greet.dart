import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;
import 'package:io/io.dart' show ExitCode;

import 'package:frontend_cli/api_types.dart';

FutureOr<int> main(List<String> args) async {
  // (1) parse the environment to prepare request
  //

  final uri = Platform.environment['GREETING_URL'] ?? 'http://localhost:8080';
  final name = args.isNotEmpty ? args[0] : 'World';

  final greetingRequest = GreetingRequest(name: name);
  final json = greetingRequest.toJson();

  print('posting request to : $uri');
  print('request body       : $json');
  print('...');

  final url = Uri.parse(uri);
  final body = jsonEncode(greetingRequest.toJson());

  // (2) send the request
  //

  final sw = Stopwatch()..start();
  http.Response res;
  try {
    res = await http.post(url,
        headers: {'content-type': 'application/json'}, body: body);
  } catch (e) {
    print('Error: ${e.toString()}');
    return io.exitCode = ExitCode.osError.code;
  }

  if (res.statusCode != io.HttpStatus.ok) {
    print('Error: HTTP status code: ${res.statusCode}');
    return io.exitCode = ExitCode.ioError.code;
  }

  // (3) display the response
  //

  final greetingResponse =
      GreetingResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  print('response: ${sw.elapsedMilliseconds} ms');
  print(greetingResponse.toJson());
  print('==> "${greetingResponse.salutation}, ${greetingResponse.name}!"');

  return io.exitCode = 0;
}
