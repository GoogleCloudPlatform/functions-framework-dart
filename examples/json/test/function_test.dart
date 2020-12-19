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

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

part 'function_test.g.dart';

@JsonSerializable(nullable: false)
class GreetingResponse {
  final String salutation;
  final String name;

  GreetingResponse({this.salutation, this.name});

  factory GreetingResponse.fromJson(Map<String, dynamic> json) =>
      _$GreetingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GreetingResponseToJson(this);

  @override
  bool operator ==(other) =>
      (other is GreetingResponse) &&
      other.salutation == salutation &&
      other.name == name;

  @override
  int get hashCode => salutation.hashCode ^ name.hashCode;
}

const defaultTimeout = Timeout(Duration(seconds: 3));

void main() {
  test('defaults', () async {
    final proc = await TestProcess.start(
        'dart', ['bin/server.dart']);

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
