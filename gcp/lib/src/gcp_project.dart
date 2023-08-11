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

import 'bad_configuration_exception.dart';
import 'metadata.dart';

/// A convenience wrapper that first tries [projectIdFromEnvironment]
/// then (if the value is `null`) tries [projectIdFromMetadataServer]
///
/// Like [projectIdFromMetadataServer], if no value is found, a
/// [BadConfigurationException] is thrown.
Future<String> computeProjectId() =>
    MetadataValue.project.fromEnvironmentOrMetadata();

/// Returns the
/// [Project ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)
/// for the current Google Cloud Project by checking the environment variables
/// in [gcpProjectIdEnvironmentVariables].
///
/// The list is checked in order. This is useful for local development.
///
/// If no matching variable is found, `null` is returned.
String? projectIdFromEnvironment() => MetadataValue.project.fromEnvironment();

/// Returns a [Future] that completes with the
/// [Project ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)
/// for the current Google Cloud Project by checking
/// [project metadata](https://cloud.google.com/compute/docs/metadata/default-metadata-values#project_metadata).
///
/// If the metadata server cannot be contacted, a [BadConfigurationException] is
/// thrown.
Future<String> projectIdFromMetadataServer() =>
    MetadataValue.project.fromMetadataServer();

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
Set<String> get gcpProjectIdEnvironmentVariables =>
    MetadataValue.project.environmentValues;
