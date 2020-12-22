// GENERATED CODE - DO NOT MODIFY BY HAND

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
