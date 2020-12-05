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
import 'package:shelf/shelf.dart';

@CloudFunction()
Response syncFunction(Request request) => throw UnimplementedError();

@CloudFunction()
Future<Response> asyncFunction(Request request) => throw UnimplementedError();

@CloudFunction()
FutureOr<Response> futureOrFunction(Request request) =>
    throw UnimplementedError();

@CloudFunction()
Response extraParam(Request request, [int other]) => throw UnimplementedError();

@CloudFunction()
Response optionalParam([Request request, int other]) =>
    throw UnimplementedError();

@CloudFunction()
Response objectParam(Object request) => throw UnimplementedError();

@CloudFunction()
_MyResponse customResponse(Object request) => throw UnimplementedError();

@CloudFunction()
Future<_MyResponse> customResponseAsync(Object request) =>
    throw UnimplementedError();

@CloudFunction()
FutureOr<_MyResponse> customResponseFutureOr(Object request) =>
    throw UnimplementedError();

abstract class _MyResponse extends Response {
  _MyResponse(int statusCode) : super(statusCode);
}
