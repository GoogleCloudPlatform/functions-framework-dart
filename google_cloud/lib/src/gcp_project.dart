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
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'constants.dart';
import 'metadata.dart';

/// A convenience wrapper that tries multiple strategies to find the project ID,
/// prioritizing local development strategies over cloud discovery.
///
/// The strategies are tried in the following order:
///
/// * [projectIdFromEnvironmentVariables]
/// * [projectIdFromCredentialsFile]
/// * [projectIdFromGcloudConfig]
/// * [projectIdFromMetadataServer]
///
/// To understand the behavior of [refresh] and the caching behavior, see
/// [projectIdFromMetadataServer].
Future<String> computeProjectId({bool refresh = false}) async {
  if (refresh) {
    _cachedComputeProjectId = null;
  }
  return _cachedComputeProjectId ??=
      projectIdFromEnvironmentVariables() ??
      projectIdFromCredentialsFile() ??
      await projectIdFromGcloudConfig() ??
      await () async {
        try {
          return await projectIdFromMetadataServer(refresh: refresh);
        } on MetadataServerException catch (e) {
          throw MetadataServerException._(
            '''
If not running on Google Cloud, one of these environment variables must be set
to the target Google Project ID:
${projectIdEnvironmentVariableOptions.join('\n')}

Alternatively, set $credentialsPathEnvironmentVariable to point to a service account
JSON file that contains a "project_id" field.

If you are running locally, you can also set the default project in the Google
Cloud SDK by running:
`gcloud config set project <PROJECT_ID>`
''',
            innerException: e.innerException,
            innerStackTrace: e.innerStackTrace,
          );
        }
      }();
}

/// Returns the
/// [Project ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)
/// for the current Google Cloud Project by checking the environment variables
/// in [projectIdEnvironmentVariableOptions].
///
/// The list is checked in order. This is useful for local development.
///
/// If no matching variable is found, `null` is returned.
String? projectIdFromEnvironmentVariables() {
  for (var key in projectIdEnvironmentVariableOptions) {
    final value = Platform.environment[key];
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }

  return null;
}

/// Returns the
/// [Project ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)
/// for the current Google Cloud Project by reading the `project_id` field
/// from the credentials JSON file specified by the
/// `GOOGLE_APPLICATION_CREDENTIALS` environment variable.
///
/// This is useful for local development when using a service account JSON file
/// for authentication, as it allows the project ID to be automatically
/// discovered from the credentials file without requiring an additional
/// environment variable.
///
/// If the environment variable is not set, the file doesn't exist, or the file
/// is invalid JSON, `null` is returned.
String? projectIdFromCredentialsFile() {
  final path = Platform.environment[credentialsPathEnvironmentVariable];
  if (path == null) return null;

  try {
    final json =
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    return json['project_id'] as String?;
  } catch (e) {
    // If file doesn't exist or is invalid, return null
    return null;
  }
}

/// Returns a [Future] that completes with the
/// [Project ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)
/// for the current Google Cloud Project by querying the gcloud CLI
/// configuration.
///
/// Note: this functions runs `gcloud config config-helper --format json` and
/// parses the output.
///
/// If gcloud is not installed, not in PATH, or fails to execute, `null` is
/// returned.
///
/// This is useful for local development when developers have authenticated
/// using `gcloud auth application-default login` and set their project using
/// `gcloud config set project PROJECT_ID`. The project ID is automatically
/// discovered from the gcloud CLI without requiring additional environment
/// variables.
Future<String?> projectIdFromGcloudConfig() async {
  try {
    final result = await Process.run('gcloud', [
      'config',
      'config-helper',
      '--format',
      'json',
    ]);

    if (result.exitCode != 0) return null;

    final stdout = result.stdout;
    if (stdout is! String || stdout.isEmpty) return null;

    return switch (jsonDecode(stdout)) {
      {
        'configuration': {
          'properties': {'core': {'project': final String project}},
        },
      } =>
        project,
      _ => null,
    };
  } catch (e) {
    // If gcloud is not installed or fails, return null
    return null;
  }
}

/// Cached project ID from [computeProjectId].
String? _cachedComputeProjectId;

/// Cached project ID from [projectIdFromMetadataServer].
String? _cachedMetadataProjectId;

/// Cached service account email to avoid redundant discovery operations.
String? _cachedServiceAccountEmail;

/// Returns a [Future] that completes with the
/// [Project ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)
/// for the current Google Cloud Project by checking
/// [project metadata](https://cloud.google.com/compute/docs/metadata/default-metadata-values#project_metadata).
///
/// {@template google_cloud.gcp_project.metadata_server_discovery}
/// The result is cached for the lifetime of the Dart process. Subsequent calls
/// return the cached value without performing discovery again.
///
/// If [client] is provided, it is used to make the request to the metadata
/// server.
///
/// If [refresh] is `true`, the cache is cleared and the value is re-computed.
///
/// If the metadata server cannot be contacted or returns a non-200 status code,
/// a [MetadataServerException] is thrown.
/// {@endtemplate}
Future<String> projectIdFromMetadataServer({
  http.Client? client,
  bool refresh = false,
}) async {
  if (refresh) {
    _cachedMetadataProjectId = null;
  }
  return _cachedMetadataProjectId ??= await getMetadataValue(
    'project/project-id',
    client: client,
  );
}

/// A convenience wrapper that tries to retrieve the default service account
/// email from the Metadata Server.
///
/// {@macro google_cloud.gcp_project.metadata_server_discovery}
Future<String> serviceAccountEmailFromMetadataServer({
  http.Client? client,
  bool refresh = false,
}) async {
  if (refresh) {
    _cachedServiceAccountEmail = null;
  }
  return _cachedServiceAccountEmail ??= await getMetadataValue(
    'instance/service-accounts/default/email',
    client: client,
  );
}

@internal
/// Retrieves a value from the GCE metadata server.
///
/// If [client] is provided, it is used to make the request to the metadata
/// server.
///
/// If the metadata server cannot be contacted or returns a non-200 status code,
/// a [MetadataServerException] is thrown.
///
/// The request should complete almost immediately if the metadata server is
/// available. If the metadata server is not available, the request will timeout
/// after [timeout].
///
/// [timeout] defaults to 1 second, which we set to a very low value to avoid
/// waiting too long.
Future<String> getMetadataValue(
  String path, {
  http.Client? client,
  Duration timeout = const Duration(seconds: 1),
}) async {
  final url = gceMetadataUrl(path);

  try {
    final abortTrigger = Completer<void>();
    final request = http.AbortableRequest(
      'GET',
      url,
      abortTrigger: abortTrigger.future,
    )..headers.addAll(metadataFlavorHeaders);

    final actualClient = client ?? http.Client();
    http.Response response;
    Timer? timeoutTimer;
    try {
      timeoutTimer = Timer(timeout, () {
        if (!abortTrigger.isCompleted) {
          abortTrigger.complete();
        }
      });

      final responseStream = await actualClient.send(request);
      response = await http.Response.fromStream(responseStream);
      timeoutTimer.cancel();
    } catch (e) {
      timeoutTimer?.cancel();
      if (abortTrigger.isCompleted) {
        throw TimeoutException('Metadata server check timed out');
      }
      rethrow;
    } finally {
      if (client == null) {
        actualClient.close();
      }
    }

    if (response.statusCode != 200) {
      throw MetadataServerException._(
        '${response.body} (${response.statusCode})',
      );
    }

    return response.body.trim();
  } on TimeoutException catch (e, stackTrace) {
    throw MetadataServerException._(
      'Metadata server check timed out.',
      innerException: e,
      innerStackTrace: stackTrace,
    );
  } on SocketException catch (e, stackTrace) {
    throw MetadataServerException._(
      'Could not connect to $gceMetadataHost.',
      innerException: e,
      innerStackTrace: stackTrace,
    );
  } on http.ClientException catch (e, stackTrace) {
    throw MetadataServerException._(
      'HTTP Client Exception when connecting to $gceMetadataHost.',
      innerException: e,
      innerStackTrace: stackTrace,
    );
  }
}

/// Exception thrown when accessing the GCE metadata server fails.
final class MetadataServerException implements Exception {
  /// The message explaining the error.
  final String message;

  /// The inner exception that caused this failure, if any.
  final Object? innerException;

  /// The stack trace of the inner exception, if any.
  final StackTrace? innerStackTrace;

  MetadataServerException._(
    this.message, {
    this.innerException,
    this.innerStackTrace,
  });

  @override
  String toString() => 'MetadataServerException: $message';
}
