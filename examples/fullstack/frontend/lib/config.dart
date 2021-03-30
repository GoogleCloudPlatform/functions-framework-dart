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

extension enumToString on Environment {
  String toName() {
    return this.toString().split('.').last;
  }
}

extension stringToEnvironment on String {
  Environment parseEnvironment() {
    switch (this) {
      case 'dev':
        return Environment.dev;
      case 'prod':
        return Environment.prod;
      default:
        throw Exception('Parsing as Environment enum exception: ${this}');
    }
  }
}

class Config {
  final String greetingsUrl;

  Config({required this.greetingsUrl});

  static Future<Config> load(Environment env) async {
    var file = 'assets/config/${env.toName()}.json';
    final data = await rootBundle.loadString(file);
    final json = jsonDecode(data);
    return Config(greetingsUrl: json['greetingUrl']);
  }

  static Future<Config> parse(String environment) async {
    final Environment env = environment.parseEnvironment();
    return await load(env);
  }
}
