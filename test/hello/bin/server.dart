// GENERATED CODE - DO NOT MODIFY BY HAND
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

import 'package:functions_framework/serve.dart';
import 'package:hello_world_function_test/functions.dart' as function_library;

Future<void> main(List<String> args) async {
  await serve(args, _functions);
}

const _functions = <FunctionEndpoint>{
  FunctionEndpoint.http(
    'function',
    function_library.function,
  ),
  FunctionEndpoint.httpWithLogger(
    'loggingHandler',
    function_library.loggingHandler,
  ),
  FunctionEndpoint.cloudEventWithContext(
    'basicCloudEventHandler',
    function_library.basicCloudEventHandler,
  ),
  FunctionEndpoint.http(
    'conformanceHttp',
    function_library.conformanceHttp,
  ),
  FunctionEndpoint.cloudEvent(
    'conformanceCloudEvent',
    function_library.conformanceCloudEvent,
  ),
  CustomTypeWithContextFunctionEndPoint.voidResult(
    'pubSubHandler',
    function_library.pubSubHandler,
    _factory5,
  ),
  CustomTypeWithContextFunctionEndPoint(
    'jsonHandler',
    function_library.jsonHandler,
    _factory6,
  ),
};

function_library.PubSub _factory5(Object json) {
  if (json is Map<String, dynamic>) {
    return function_library.PubSub.fromJson(json);
  }
  throw BadRequestException(
    400,
    'The provided JSON is not the expected type `Map<String, dynamic>`.',
  );
}

Map<String, dynamic> _factory6(Object json) {
  if (json is Map<String, dynamic>) {
    return json;
  }
  throw BadRequestException(
    400,
    'The provided JSON is not the expected type `Map<String, dynamic>`.',
  );
}
