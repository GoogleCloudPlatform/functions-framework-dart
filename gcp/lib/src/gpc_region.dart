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

/// A convenience wrapper that first tries [regionFromEnvironment]
/// then (if the value is `null`) tries [regionFromMetadataServer]
///
/// Like [regionFromMetadataServer], if no value is found, a
/// [BadConfigurationException] is thrown.
Future<String> computeRegion() async {
  final localValue = regionFromEnvironment();
  if (localValue != null) {
    return localValue;
  }
  final result = await regionFromMetadataServer();

  return result;
}

/// Returns the
/// [Region](https://cloud.google.com/compute/docs/regions-zones#identifying_a_region_or_zone)
/// for the current instance by checking the environment variables
/// in [gcpRegionEnvironmentVariables].
///
/// The list is checked in order. This is useful for local development.
///
/// If no matching variable is found, `null` is returned.
String? regionFromEnvironment() {
  for (var envKey in gcpRegionEnvironmentVariables) {
    final value = Platform.environment[envKey];
    if (value != null) return value;
  }

  return null;
}

/// Returns a [Future] that completes with the
/// [Region](https://cloud.google.com/compute/docs/regions-zones#identifying_a_region_or_zone)
/// for the current instance by checking
/// [instance metadata](https://cloud.google.com/compute/docs/metadata/default-metadata-values#vm_instance_metadata).
///
/// If the metadata server cannot be contacted, a [BadConfigurationException] is
/// thrown.
Future<String> regionFromMetadataServer() async {
  const host = 'http://metadata.google.internal/';
  final url = Uri.parse('$host/computeMetadata/v1/instance/region');

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
to the target region:
${gcpRegionEnvironmentVariables.join('\n')}
''',
      details: e.toString(),
    );
  }
}

/// A set of typical environment variables that are likely to represent the
/// current Google Cloud instance region.
///
/// For context, see:
/// * https://cloud.google.com/functions/docs/env-var
/// * https://cloud.google.com/compute/docs/gcloud-compute#default_project
/// * https://github.com/GoogleContainerTools/gcp-auth-webhook/blob/08136ca171fe5713cc70ef822c911fbd3a1707f5/server.go#L38-L44
///
/// Note: these are ordered starting from the most current/canonical to least.
/// (At least as could be determined at the time of writing.)
const gcpRegionEnvironmentVariables = {
  'FUNCTION_REGION',
  'CLOUDSDK_COMPUTE_REGION',
};
