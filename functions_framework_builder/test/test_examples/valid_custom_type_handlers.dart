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

import 'package:functions_framework/functions_framework.dart';

@CloudFunction()
void syncFunction(JsonType request) => throw UnimplementedError();

@CloudFunction()
Future<void> asyncFunction(JsonType request) => throw UnimplementedError();

@CloudFunction()
FutureOr<void> futureOrFunction(JsonType request) => throw UnimplementedError();

@CloudFunction()
void extraParam(JsonType request, [int? other]) => throw UnimplementedError();

@CloudFunction()
void optionalParam([JsonType? request, int? other]) =>
    throw UnimplementedError();

class JsonType {
  // ignore: avoid_unused_constructor_parameters
  factory JsonType.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}
