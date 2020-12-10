// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

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
