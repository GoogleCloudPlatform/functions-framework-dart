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

/// General Google Cloud Platform integration features.
///
/// {@canonicalFor gcp_project.computeProjectId}
/// {@canonicalFor gcp_project.projectIdFromCredentialsFile}
/// {@canonicalFor gcp_project.projectIdFromEnvironmentVariables}
/// {@canonicalFor gcp_project.projectIdFromGcloudConfig}
/// {@canonicalFor gcp_project.MetadataServerException}
/// {@canonicalFor gcp_project.projectIdFromMetadataServer}
/// {@canonicalFor gcp_project.serviceAccountEmailFromMetadataServer}
/// {@canonicalFor logging.LogSeverity}
/// {@canonicalFor logging.structuredLogEntry}
/// {@canonicalFor metadata.gceMetadataHost}
/// {@canonicalFor metadata.gceMetadataUrl}
library;

export 'src/gcp_project.dart'
    show
        MetadataServerException,
        computeProjectId,
        getMetadataValue,
        projectIdFromCredentialsFile,
        projectIdFromEnvironmentVariables,
        projectIdFromGcloudConfig,
        projectIdFromMetadataServer,
        serviceAccountEmailFromMetadataServer;
export 'src/logging.dart' show LogSeverity, structuredLogEntry;
export 'src/metadata.dart' show gceMetadataHost, gceMetadataUrl;
