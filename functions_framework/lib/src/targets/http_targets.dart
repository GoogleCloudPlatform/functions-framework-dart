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

import 'package:shelf/shelf.dart';

import '../function_target.dart';
import '../logging.dart';
import '../typedefs.dart';

class HttpFunctionTarget extends FunctionTarget {
  final Handler _function;

  @override
  FutureOr<Response> handler(Request request) => _function(request);

  const HttpFunctionTarget(String target, this._function) : super(target);
}

class HttpWithLoggerFunctionTarget extends FunctionTarget {
  final HandlerWithLogger _function;

  @override
  FutureOr<Response> handler(Request request) =>
      _function(request, loggerForRequest(request));

  const HttpWithLoggerFunctionTarget(String target, this._function)
      : super(target);
}
