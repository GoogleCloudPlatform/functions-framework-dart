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

import 'dart:io';

import 'package:http/http.dart' as http;

import 'bad_configuration_exception.dart';

/// Returns a [Future] that completes with the
/// [Project ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)
/// for the current Google Cloud Project.
///
/// First, if an environment variable with a name in
/// [gcpProjectIdEnvironmentVariables] exists, that is returned.
/// (The list is checked in order.) This is useful for local development.
///
/// If no such environment variable exists (or [metadataServerOnly] is `true`),
/// then we assume the code is running on Google Cloud and
/// [Project metadata](https://cloud.google.com/compute/docs/metadata/default-metadata-values#project_metadata)
/// is queried for the Project ID.
///
/// If the metadata server cannot be contacted, a [BadConfigurationException] is
/// thrown.
Future<String> currentProjectId({bool metadataServerOnly = false}) async {
  if (!metadataServerOnly) {
    for (var envKey in gcpProjectIdEnvironmentVariables) {
      final value = Platform.environment[envKey];
      if (value != null) return value;
    }
  }

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
    throw BadConfigurationException(
      '''
Could not connect to $host.
If not running on Google Cloud, one of these environment variables must be set
to the target Google Project ID:
${gcpProjectIdEnvironmentVariables.join('\n')}
''',
      details: e.toString(),
    );
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
