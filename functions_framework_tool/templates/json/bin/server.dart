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
import 'package:example_json_function/functions.dart' as function_library;

Future<void> main(List<String> args) async {
  await serve(args, _functionTargets);
}

const _functionTargets = <FunctionTarget>{
  JsonFunctionTarget(
    'function',
    function_library.function,
    _factory0,
  ),
};

Map<String, dynamic> _factory0(Object json) {
  if (json is Map<String, dynamic>) {
    return json;
  }
  throw BadRequestException(
    400,
    'The provided JSON is not the expected type `Map<String, dynamic>`.',
  );
}
