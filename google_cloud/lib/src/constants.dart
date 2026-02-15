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
/// * https://github.com/googleapis/google-auth-library-nodejs/blob/main/src/auth/googleauth.ts
/// * https://cloud.google.com/functions/docs/env-var
///
/// Note: these are ordered starting from the most current/canonical to least.
/// (At least as could be determined at the time of writing.)
const projectIdEnvironmentVariableOptions = {
  projectIdEnvironmentVariable,
  'GCP_PROJECT',
  'GCLOUD_PROJECT',
  'CLOUDSDK_CORE_PROJECT',
};

/// The standard environment variable for specifying the Google Cloud project
/// ID.
const projectIdEnvironmentVariable = 'GOOGLE_CLOUD_PROJECT';

/// The default port a service should listen on if [portEnvironmentVariable] is
/// not set.
const defaultListenPort = 8080;

/// Standard HTTP header used by
/// [Cloud Trace](https://cloud.google.com/trace/docs/setup).
const cloudTraceContextHeader = 'x-cloud-trace-context';

/// Standard HTTP request headers expected by the
/// [Metadata Server](https://cloud.google.com/compute/docs/metadata).
const metadataFlavorHeaders = {'Metadata-Flavor': 'Google'};

/// The name of the Cloud Run service being run.
const serviceEnvironmentVariable = 'K_SERVICE';

/// The name of the Cloud Run revision being run.
const revisionEnvironmentVariable = 'K_REVISION';

/// The name of the Cloud Run configuration being run.
const configurationEnvironmentVariable = 'K_CONFIGURATION';
