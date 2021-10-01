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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

import 'src/pub_sub_types.dart';
import 'src/utils.dart';

export 'src/conformance_handlers.dart';
export 'src/json_handlers.dart';
export 'src/pub_sub_types.dart';

int _activeRequests = 0;
int _maxActiveRequests = 0;
int _requestCount = 0;

final _watch = Stopwatch();

@CloudFunction()
Future<Response> function(Request request) async {
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
        encodeJsonPretty(output),
        headers: _jsonHeaders,
      );
    }

    if (urlPath.startsWith('exception')) {
      throw BadRequestException(400, 'Testing `throw BadRequestException`');
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

@CloudFunction()
Response loggingHandler(Request handler, RequestLogger logger) {
  logger
    ..log('default', LogSeverity.defaultSeverity)
    ..debug('debug')
    ..info('info')
    ..notice('notice')
    ..warning('warning')
    ..error('error')
    ..critical('critical')
    ..alert('alert')
    ..emergency('emergency');

  return Response.ok('');
}

@CloudFunction()
void basicCloudEventHandler(CloudEvent event, RequestContext context) {
  context.logger.info('event subject: ${event.subject}');

  final pubSub = PubSub.fromJson(event.data as Map<String, dynamic>);

  context.responseHeaders['x-attribute_count'] =
      pubSub.message.attributes.length.toString();

  stderr.writeln(encodeJsonPretty(event));
}

final _helloWorldBytes = utf8.encode('Hello, World!');

const _contentTypeHeader = 'Content-Type';
const _jsonContentType = 'application/json';
const _jsonHeaders = {_contentTypeHeader: _jsonContentType};
