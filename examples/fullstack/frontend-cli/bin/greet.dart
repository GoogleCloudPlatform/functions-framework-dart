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
