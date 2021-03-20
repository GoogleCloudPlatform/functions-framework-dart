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
void syncFunction(num request) => throw UnimplementedError();

@CloudFunction()
Future<void> asyncFunction(num request) => throw UnimplementedError();

@CloudFunction()
FutureOr<void> futureOrFunction(num request) => throw UnimplementedError();

@CloudFunction()
void extraParam(num request, [int? other]) => throw UnimplementedError();

@CloudFunction()
void optionalParam([num? request, int? other]) => throw UnimplementedError();
