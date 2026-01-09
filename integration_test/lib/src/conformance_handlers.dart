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

import 'utils.dart';

@CloudFunction()
Future<Response> conformanceHttp(Request request) async {
  final content = await request.readAsString();

  File('function_output.json').writeAsStringSync(content);

  final buffer = StringBuffer()
    ..writeln('Hello, conformance test!')
    ..writeln('HEADERS')
    ..writeln(encodeJsonPretty(request.headers))
    ..writeln('BODY')
    ..writeln(encodeJsonPretty(jsonDecode(content)));

  final output = buffer.toString();
  print(output);
  return Response.ok(output);
}

@CloudFunction()
void conformanceCloudEvent(CloudEvent event) {
  final eventEncoded = encodeJsonPretty(event);
  File('function_output.json').writeAsStringSync(eventEncoded);

  final buffer = StringBuffer()
    ..writeln('Hello, conformance test!')
    ..writeln('EVENT')
    ..writeln(eventEncoded);

  print(buffer.toString());
}
