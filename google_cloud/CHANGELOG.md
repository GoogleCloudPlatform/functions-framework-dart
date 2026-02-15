## 0.3.0

### BREAKING CHANGES

- Split the library into two main entry points:
  - `package:google_cloud/general.dart` for general GCP features like project
    discovery, identity discovery, and core structured logging.
  - `package:google_cloud/http_serving.dart` for HTTP serving features like
    port discovery, shelf middleware, and signal handling.
  - `package:google_cloud/google_cloud.dart` remains as an umbrella library
    exporting both.
- Renamed `projectIdFromEnvironment()` to `projectIdFromEnvironmentVariables()`.
- Renamed `portEnvironmentKey` to `portEnvironmentVariable`.
- Renamed `listenPort()` to `listenPortFromEnvironment()`.
- `computeProjectId()`, `projectIdFromMetadataServer()`, and
  `serviceAccountEmailFromMetadataServer()` now leverage a unified process-wide
  metadata cache.
- **Breaking Change**: Local discovery strategies (environment variables,
  credentials files, and `gcloud` config) are no longer cached.
- **Breaking Change**: `projectIdFromMetadataServer()` and
  `serviceAccountEmailFromMetadataServer()` now throw
  `MetadataServerException` (which wraps `SocketException`, `TimeoutException`,
  or `ClientException`) when discovery fails.
- Constants are now exported via `package:google_cloud/constants.dart` and are
  no longer exported by `package:google_cloud/google_cloud.dart`.
- Require Dart 3.9.
- Require `package:http` `^1.1.0`.

### New Features

- Added `getMetadataValue()` (caching) and `fetchMetadataValue()` (non-caching)
  to `package:google_cloud/general.dart`.
- Added `projectIdFromCredentialsFile()` to automatically discover project ID
  from the credentials JSON file.
- Added `projectIdFromGcloudConfig()` to automatically discover project ID from
  gcloud CLI configuration.
- Added `serviceAccountEmailFromMetadataServer()` to discover the default
  service account email.
- Added `gceMetadataHost` and `gceMetadataUrl` to interact with the metadata
  server.
- `projectIdFromMetadataServer()` now respects the `GCE_METADATA_HOST`
  environment variable.
- Added `refresh` parameter to `computeProjectId()`,
  `projectIdFromMetadataServer()`, and `serviceAccountEmailFromMetadataServer()`
  to force re-discovery.
- Added `client` parameter to `computeProjectId()`,
  `projectIdFromMetadataServer()`, and `serviceAccountEmailFromMetadataServer()`
  to allow providing a custom `http.Client`.
- Added `structuredLogEntry()` for low-level structured log creation.

## 0.2.0

- First release replacing `package:gcp`.
