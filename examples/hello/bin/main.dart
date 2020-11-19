import 'package:functions_framework/serve.dart';
import 'package:shelf/shelf.dart';

import 'package:hello_world_function/app.dart' as prefix00;

Future<void> main(List<String> args) async {
  await serve(args, _functions);
}

const _functions = <String, Handler>{
  'function': prefix00.handleGet,
};
