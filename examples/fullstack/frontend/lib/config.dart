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

import 'package:flutter/services.dart';

enum Environment {
  dev,
  prod,
}

class Config {
  final String greetingsUrl;

  Config({required this.greetingsUrl});

  static Future<Config> load(Environment env) async {
    final file = 'assets/config/${env.name}.json';
    final data = await rootBundle.loadString(file);
    final json = jsonDecode(data) as Map<String, dynamic>;
    return Config(greetingsUrl: json['greetingUrl'] as String);
  }

  static Future<Config> parse(String environment) async {
    final env = Environment.values.byName(environment);
    return await load(env);
  }
}
