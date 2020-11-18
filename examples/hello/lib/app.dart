@function
library app;

import 'package:functions_framework_dart/functions_framework.dart';
import 'package:shelf/shelf.dart';

Response handleGet(Request request) => Response.ok('Hello, World!');
