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

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'bad_configuration_exception.dart';

/// Cached project ID to avoid redundant discovery operations.
String? _cachedProjectId;

/// A convenience wrapper that first tries [projectIdFromEnvironment],
/// then [projectIdFromCredentialsFile], then [projectIdFromGcloudConfig],
/// and finally [projectIdFromMetadataServer]
///
/// The result is cached for the lifetime of the Dart process. Subsequent calls
/// return the cached value without performing discovery again.
///
/// Like [projectIdFromMetadataServer], if no value is found, a
/// [BadConfigurationException] is thrown.
Future<String> computeProjectId() async {
  // Return cached value if available
  if (_cachedProjectId != null) {
    return _cachedProjectId!;
  }

  final localValue = projectIdFromEnvironment();
  if (localValue != null) {
    _cachedProjectId = localValue;
    return localValue;
  }

  final credentialsValue = projectIdFromCredentialsFile();
  if (credentialsValue != null) {
    _cachedProjectId = credentialsValue;
    return credentialsValue;
  }

  final gcloudValue = await projectIdFromGcloudConfig();
  if (gcloudValue != null) {
    _cachedProjectId = gcloudValue;
    return gcloudValue;
  }

  final result = await projectIdFromMetadataServer();
  _cachedProjectId = result;

  return result;
}

/// Clears the cached project ID.
///
/// This is primarily useful for testing scenarios where the project ID
/// might change between tests, or when you need to force re-discovery
/// of the project ID.
void clearProjectIdCache() {
  _cachedProjectId = null;
}

/// Returns the
/// [Project ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)
/// for the current Google Cloud Project by checking the environment variables
/// in [gcpProjectIdEnvironmentVariables].
///
/// The list is checked in order. This is useful for local development.
///
/// If no matching variable is found, `null` is returned.
String? projectIdFromEnvironment() {
  for (var envKey in gcpProjectIdEnvironmentVariables) {
    final value = Platform.environment[envKey];
    if (value != null) return value;
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
  final path = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
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
/// This is useful for local development when developers have authenticated
/// using `gcloud auth application-default login` and set their project using
/// `gcloud config set project PROJECT_ID`. The project ID is automatically
/// discovered from the gcloud CLI without requiring additional environment
/// variables.
///
/// If gcloud is not installed, not in PATH, or fails to execute, `null` is
/// returned.
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

    final json = jsonDecode(stdout) as Map<String, dynamic>;
    final configuration = json['configuration'] as Map<String, dynamic>?;
    if (configuration == null) return null;

    final properties = configuration['properties'] as Map<String, dynamic>?;
    if (properties == null) return null;

    final core = properties['core'] as Map<String, dynamic>?;
    if (core == null) return null;

    return core['project'] as String?;
  } catch (e) {
    // If gcloud is not installed or fails, return null
    return null;
  }
}

/// Returns a [Future] that completes with the
/// [Project ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)
/// for the current Google Cloud Project by checking
/// [project metadata](https://cloud.google.com/compute/docs/metadata/default-metadata-values#project_metadata).
///
/// If the metadata server cannot be contacted, a [BadConfigurationException] is
/// thrown.
Future<String> projectIdFromMetadataServer() async {
  const host = 'http://metadata.google.internal/';
  final url = Uri.parse('$host/computeMetadata/v1/project/project-id');

  try {
    final response = await http.get(
      url,
      headers: {'Metadata-Flavor': 'Google'},
    );

    if (response.statusCode != 200) {
      throw HttpException(
        '${response.body} (${response.statusCode})',
        uri: url,
      );
    }

    return response.body;
  } on SocketException catch (e) {
    throw BadConfigurationException('''
Could not connect to $host.
If not running on Google Cloud, one of these environment variables must be set
to the target Google Project ID:
${gcpProjectIdEnvironmentVariables.join('\n')}

Alternatively, set GOOGLE_APPLICATION_CREDENTIALS to point to a service account
JSON file that contains a "project_id" field.
''', details: e.toString());
  }
}

/// A set of typical environment variables that are likely to represent the
/// current Google Cloud project ID.
///
/// For context, see:
/// * https://cloud.google.com/functions/docs/env-var
/// * https://cloud.google.com/compute/docs/gcloud-compute#default_project
/// * https://github.com/GoogleContainerTools/gcp-auth-webhook/blob/08136ca171fe5713cc70ef822c911fbd3a1707f5/server.go#L38-L44
///
/// Note: these are ordered starting from the most current/canonical to least.
/// (At least as could be determined at the time of writing.)
const gcpProjectIdEnvironmentVariables = {
  'GCP_PROJECT',
  'GCLOUD_PROJECT',
  'CLOUDSDK_CORE_PROJECT',
  'GOOGLE_CLOUD_PROJECT',
};
