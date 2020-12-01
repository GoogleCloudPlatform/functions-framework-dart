// Copyright 2020 Google LLC
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
import 'dart:io';

import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction()
Response handleGet(Request request) {
  final urlPath = request.url.path;

  if (urlPath.startsWith('info')) {
    final output = {
      'request': request.requestedUri.toString(),
      'headers': request.headers,
      'environment': Platform.environment,
    };

    return Response.ok(
      JsonUtf8Encoder('  ').convert(output),
      headers: _jsonHeaders,
    );
  }

  if (urlPath.startsWith('error')) {
    throw Exception('An error with forced by requesting "$urlPath"');
  }

  return Response.ok('Hello, World!');
}

const _jsonHeaders = {'Content-Type': 'application/json'};
