// GENERATED CODE - DO NOT MODIFY BY HAND
// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// @dart=3.6

import 'package:functions_framework/serve.dart';
import 'package:hello_world_function_test/functions.dart' as function_library;

Future<void> main(List<String> args) async {
  await serve(args, _nameToFunctionTarget);
}

FunctionTarget? _nameToFunctionTarget(String name) => switch (name) {
      'function' => FunctionTarget.http(
          function_library.function,
        ),
      'loggingHandler' => FunctionTarget.httpWithLogger(
          function_library.loggingHandler,
        ),
      'basicCloudEventHandler' => FunctionTarget.cloudEventWithContext(
          function_library.basicCloudEventHandler,
        ),
      'protoEventHandler' => FunctionTarget.cloudEventWithContext(
          function_library.protoEventHandler,
        ),
      'conformanceHttp' => FunctionTarget.http(
          function_library.conformanceHttp,
        ),
      'conformanceCloudEvent' => FunctionTarget.cloudEvent(
          function_library.conformanceCloudEvent,
        ),
      'pubSubHandler' => JsonWithContextFunctionTarget.voidResult(
          function_library.pubSubHandler,
          (json) {
            if (json is Map<String, dynamic>) {
              try {
                return function_library.PubSub.fromJson(json);
              } catch (e, stack) {
                throw BadRequestException(
                  400,
                  'There was an error parsing the provided JSON data.',
                  innerError: e,
                  innerStack: stack,
                );
              }
            }
            throw BadRequestException(
              400,
              'The provided JSON is not the expected type '
              '`Map<String, dynamic>`.',
            );
          },
        ),
      'jsonHandler' => JsonWithContextFunctionTarget(
          function_library.jsonHandler,
          (json) {
            if (json is Map<String, dynamic>) {
              return json;
            }
            throw BadRequestException(
              400,
              'The provided JSON is not the expected type '
              '`Map<String, dynamic>`.',
            );
          },
        ),
      _ => null
    };
