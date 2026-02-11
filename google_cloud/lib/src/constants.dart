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

/// The standard environment variable for specifying the port a service should
/// listen on.
const portEnvironmentVariable = 'PORT';

/// Standard environment variable for specifying the path to a service account
/// JSON file.
///
/// See: https://docs.cloud.google.com/docs/authentication/application-default-credentials
const credentialsPathEnvironmentVariable = 'GOOGLE_APPLICATION_CREDENTIALS';

/// A set of standard environment variables that are likely to represent the
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

/// The default port a service should listen on if [portEnvironmentVariable] is
/// not set.
const defaultListenPort = 8080;

/// Standard HTTP header used by
/// [Cloud Trace](https://cloud.google.com/trace/docs/setup).
const cloudTraceContextHeader = 'x-cloud-trace-context';

/// Standard HTTP request headers expected by the
/// [Metadata Server](https://cloud.google.com/compute/docs/metadata).
const metadataFlavorHeaders = {'Metadata-Flavor': 'Google'};
