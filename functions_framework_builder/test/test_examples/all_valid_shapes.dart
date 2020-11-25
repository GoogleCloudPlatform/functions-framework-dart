// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction('sync')
Response handleGet(Request request) => Response.ok('Hello, World!');

@CloudFunction('async')
Future<Response> handleGet2(Request request) async =>
    Response.ok('Hello, World!');

@CloudFunction('futureOr')
FutureOr<Response> handleGet3(Request request) => Response.ok('Hello, World!');
