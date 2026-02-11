[![pub package](https://img.shields.io/pub/v/google_cloud.svg)](https://pub.dev/packages/google_cloud)
[![package publisher](https://img.shields.io/pub/publisher/google_cloud.svg)](https://pub.dev/packages/google_cloud/publisher)

> NOTE: This is a **community-supported project**, meaning there is no official
> level of support. The code is not covered by any SLA or deprecation policy.
>
> Feel free to start a [discussion] to share thoughts or open [issues] for bugs
> and feature requests.

Utilities for running Dart code correctly on the Google Cloud Platform.

## Features

This package is split into two main libraries:

### General GCP Features (`package:google_cloud/general.dart`)

- **Project Discovery**: Automatically discover the Google Cloud [Project ID] using multiple strategies:
  - Environment variables (e.g., `GOOGLE_CLOUD_PROJECT`).
  - Service account credentials file (`GOOGLE_APPLICATION_CREDENTIALS`).
  - `gcloud` CLI configuration.
  - Google Cloud [Metadata Server].
- **Identity Discovery**: Retrieve the default [service account email].
- **Core Structured Logging**: Low-level utilities for creating [structured logs][structured logging]
  that integrate with Google Cloud Logging.

### HTTP Serving (`package:google_cloud/http_serving.dart`)

- **Port Discovery**: Access the configured listening port via `listenPortFromEnvironment()`.
- **Structured Logging**: Shelf middleware for [structured logging] that integrates with Google Cloud Logging.
- **Process Lifecycle**: Utilities for [handling termination signals] (`SIGINT`, `SIGTERM`) to allow for graceful shutdown.

> NOTE: `package:google_cloud/google_cloud.dart` exports both libraries for convenience.

## Usage

### Project Discovery

```dart
import 'package:google_cloud/general.dart';

void main() async {
  // Discovers the project ID using all available strategies.
  // The result is cached for the lifetime of the process.
  final projectId = await computeProjectId();
  print('Running in project: $projectId');
}
```

### Structured Logging and Serving

```dart
import 'package:google_cloud/general.dart';
import 'package:google_cloud/http_serving.dart';
import 'package:shelf/shelf.dart';

void main() async {
  final projectId = await computeProjectId();

  final handler = const Pipeline()
      .addMiddleware(createLoggingMiddleware(projectId: projectId))
      .addHandler((request) {
        currentLogger.info('Handling request: ${request.url}');
        return Response.ok('Hello, World!');
      });

  // Automatically listens on the correct port and handles termination signals.
  await serveHandler(handler);
}
```

[Project ID]:
  https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects
[Metadata Server]:
  https://cloud.google.com/compute/docs/metadata/default-metadata-values
[service account email]:
  https://cloud.google.com/compute/docs/metadata/default-metadata-values#service-accounts
[structured logging]:
  https://cloud.google.com/functions/docs/monitoring/logging#writing_structured_logs
[handling termination signals]:
  https://cloud.google.com/run/docs/reference/container-contract#termination-signal
[issues]: https://github.com/GoogleCloudPlatform/functions-framework-dart/issues
[discussion]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/discussions
