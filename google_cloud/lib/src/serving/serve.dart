// Copyright 2022 Google LLC
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
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import '../constants.dart';
import 'bad_configuration_exception.dart';
import 'terminate.dart';

/// Serves [handler] on [InternetAddress.anyIPv4] using the port returned by
/// [listenPortFromEnvironment].
///
/// The returned [Future] will complete using [waitForTerminate] after
/// closing the server.
Future<void> serveHandler(Handler handler) async {
  final port = listenPortFromEnvironment();

  final server = await serve(
    handler,
    InternetAddress.anyIPv4, // Allows external connections
    port,
  );
  print('Serving at http://${server.address.host}:${server.port}');

  await waitForTerminate();

  await server.close();
}

/// Returns the port to listen on from environment variable or uses the default
/// `8080`.
///
/// See https://cloud.google.com/run/docs/reference/container-contract#port
///
/// If [portEnvironmentVariable] is set, but cannot be parsed,
/// a [BadConfigurationException] is thrown.
/// Returns the number of the port allowing the function to accept requests.
///
/// This property returns the value of the environment variable defined by
/// [portEnvironmentVariable], if it is set. If the environment variable is not
/// set, or if it does not represent a valid integer value, this property
/// returns the value of [defaultListenPort].
int listenPortFromEnvironment() {
  final portStr = Platform.environment[portEnvironmentVariable];
  if (portStr != null) {
    try {
      return int.parse(portStr);
    } on FormatException catch (e) {
      throw BadConfigurationException(
        'Bad value for environment variable "$portEnvironmentVariable" – '
        '"$portStr" – ${e.message}.',
      );
    }
  }
  return defaultListenPort;
}
