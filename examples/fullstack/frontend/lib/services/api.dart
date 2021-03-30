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

import 'package:http/http.dart' as http;

import 'api_types.dart';

class Greeting {
  late Uri _uri;

  Greeting(String uri) {
    _uri = Uri.parse(uri);
  }

  // TODO: better strategy for surfacing errors, http statuscodes
  Future<GreetingResponse> getGreeting(String? name) async {
    var greetingRequest = GreetingRequest(name: name);

    var body = jsonEncode(greetingRequest.toJson());

    var res = await http.post(
      _uri,
      headers: {'content-type': 'application/json'},
      body: body,
    );

    if (res.statusCode == HttpStatus.ok) {
      var greetingResponse = GreetingResponse.fromJson(jsonDecode(res.body));
      return greetingResponse;
    }

    throw Future.error(Exception(
        'Error: unexpected HTTP status code: ${res.statusCode.toString()}'));
  }
}
