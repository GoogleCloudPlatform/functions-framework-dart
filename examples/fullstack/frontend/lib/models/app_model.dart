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

import 'package:flutter/material.dart';
import 'package:fullstack_demo_frontend/services/api_types.dart';

import '../config.dart';
import '../services/api.dart';

class AppModel with ChangeNotifier {
  Config _config;
  late Greeting _greeting;

  String? name;
  String? salutation;

  List<GreetingResponse> pastGreetings = [];

  AppModel(this._config) {
    _greeting = Greeting(_config.greetingsUrl);
  }

  Future<void> greet(String? name) async {
    try {
      var greetingResponse = await _greeting.getGreeting(name);
      pastGreetings.add(greetingResponse);
      this.name = greetingResponse.name;
      this.salutation = greetingResponse.salutation;
      notifyListeners();
    } on Exception catch (e) {
      // TODO: actual error handling strategy
      print(e);
    }
  }
}
