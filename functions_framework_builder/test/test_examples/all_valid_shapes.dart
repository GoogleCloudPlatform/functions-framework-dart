// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction('sync')
Response handleGet(Request request) => throw UnimplementedError();

@CloudFunction('async')
Future<Response> handleGet2(Request request) => throw UnimplementedError();

@CloudFunction('futureOr')
FutureOr<Response> handleGet3(Request request) => throw UnimplementedError();

@CloudFunction('extra params')
Response handleGet4(Request request, [int other]) => throw UnimplementedError();

@CloudFunction('optional positional')
Response handleGet5([Request request, int other]) => throw UnimplementedError();

// TODO: these should be fine, too – but more work is involoved
//@CloudFunction('more general param type')
Response handleGet6(Object request) => throw UnimplementedError();

//@CloudFunction('more specific return type')
_MyResponse handleGet7(Object request) => throw UnimplementedError();

//@CloudFunction('more specific return type - Future')
Future<_MyResponse> handleGet8(Object request) => throw UnimplementedError();

//@CloudFunction('more specific return type - FutureOr')
FutureOr<_MyResponse> handleGet9(Object request) => throw UnimplementedError();

abstract class _MyResponse extends Response {
  _MyResponse(int statusCode) : super(statusCode);
}
