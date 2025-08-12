import 'package:shelf/shelf.dart';

Future<Response> function(Request request) async =>
    Response.ok('Hello, World!');
