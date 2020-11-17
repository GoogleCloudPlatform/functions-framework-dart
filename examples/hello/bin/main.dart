import 'package:functions_framework_dart/configuration.dart';
import 'package:functions_framework_dart/functions_framework.dart';

import 'package:hello_world_function/app.dart' as app;

import 'main.reflectable.dart' as reflectable;

Future main(List<String> args) async {
  reflectable.initializeReflectable();
  final functionConfig = FunctionConfig.fromEnv();
  await serve(functionConfig, function.findLibrary('app'));
}
