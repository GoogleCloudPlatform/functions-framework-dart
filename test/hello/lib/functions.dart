// Copyright 2020 Google LLC
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

import 'dart:convert';
import 'dart:io';

import 'package:functions_framework/functions_framework.dart';
import 'package:pedantic/pedantic.dart';
import 'package:shelf/shelf.dart';

int _activeRequests = 0;
int _maxActiveRequests = 0;
int _requestCount = 0;
final _watch = Stopwatch();

@CloudFunction()
Future<Response> handleGet(Request request) async {
  _watch.start();
  _requestCount++;
  _activeRequests++;
  if (_activeRequests > _maxActiveRequests) {
    _maxActiveRequests = _activeRequests;
  }

  final urlPath = request.url.path;

  if (urlPath.contains('slow')) {
    // Adds a one-second pause to matching requests.
    // Good for testing concurrency
    await Future.delayed(const Duration(seconds: 1));
  }

  try {
    if (urlPath.startsWith('info')) {
      final output = {
        'request': request.requestedUri.toString(),
        'thisInstance': {
          'activeRequests': _activeRequests,
          'maxActiveRequests': _maxActiveRequests,
          'totalRequests': _requestCount,
          'upTime': _watch.elapsed.toString(),
        },
        'platform': {
          'numberOfProcessors': Platform.numberOfProcessors,
          'operatingSystem': Platform.operatingSystem,
          'operatingSystemVersion': Platform.operatingSystemVersion,
          'version': Platform.version,
        },
        'process': {
          'currentRss': ProcessInfo.currentRss,
          'maxRss': ProcessInfo.maxRss,
        },
        'headers': request.headers,
        'environment': Platform.environment,
      };

      return Response.ok(
        _encoder.convert(output),
        headers: _jsonHeaders,
      );
    }

    if (urlPath.startsWith('error')) {
      if (urlPath.contains('async')) {
        // Add a pause to the result
        await Future.value();
        unawaited(
          Future.value().then((value) => throw StateError('async error')),
        );
      }
      throw Exception('An error was forced by requesting "$urlPath"');
    }

    if (urlPath.startsWith('print')) {
      for (var segment in request.url.pathSegments) {
        print(segment);
      }
      return Response.ok('Printing: $urlPath');
    }

    if (urlPath.startsWith('binary')) {
      return Response.ok(_helloWorldBytes);
    }

    return Response.ok('Hello, World!');
  } finally {
    _activeRequests--;
  }
}

@CloudFunction('conformance')
Future<Response> conformance(Request request) async {
  final content = await request.readAsString();
  File('function_output.json').writeAsStringSync(
    content,
  );

  final buffer = StringBuffer()
    ..writeln('Hello, conformance test!')
    ..writeln('HEADERS')
    ..writeln(_encoder.convert(request.headers))
    ..writeln('BODY')
    ..writeln(_encoder.convert(jsonDecode(content)));

  final output = buffer.toString();
  print(output);
  return Response.ok(output);
}

final _helloWorldBytes = utf8.encode('Hello, World!');

const _jsonHeaders = {'Content-Type': 'application/json'};

const _encoder = JsonEncoder.withIndent(' ');
