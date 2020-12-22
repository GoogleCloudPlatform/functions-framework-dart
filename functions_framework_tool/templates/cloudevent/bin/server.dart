import 'package:functions_framework/serve.dart';
import 'package:example_raw_cloudevent_function/functions.dart'
    as function_library;

Future<void> main(List<String> args) async {
  await serve(args, _functionTargets);
}

const _functionTargets = <FunctionTarget>{
  FunctionTarget.cloudEventWithContext(
    'function',
    function_library.function,
  ),
};
