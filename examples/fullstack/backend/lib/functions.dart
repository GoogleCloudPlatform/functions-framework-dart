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

import 'dart:math';

import 'package:functions_framework/functions_framework.dart';

import 'api_types.dart';

// Export api_types so builder can use them when generating `bin/server.dart`.
export 'api_types.dart';

@CloudFunction()
GreetingResponse function(GreetingRequest request, RequestContext context) {
  final name = request.name ?? 'World';
  final response = GreetingResponse(salutation: getSalutation(), name: name);
  context.logger.info('greetingResponse: ${response.toJson()}');
  return response;
}

final Random rng = Random(DateTime.now().millisecondsSinceEpoch);

final List<String> salutations = [
  '안녕하세요', // annyeonghaseyo
  'こんにちは', // Kon'nichiwa
  '你好', // Nǐ hǎo
  'Привет', // Privet
  'สวัสดี', // S̄wạs̄dī
  'Aloha',
  'Bonjour',
  'Hello',
  'Ciao',
  'Dzień dobry',
  'Hola',
  'Hallo',
  'Kon’nichiwa',
  'Namaste',
  'Salam',
  'Shalom',
  'Tena koutou',
];

String getSalutation() {
  return salutations[rng.nextInt(salutations.length)];
}
