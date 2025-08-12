# Functions Framework for Dart

> This is a **community-supported project**, meaning there is no official level
> of support. The code is not covered by any SLA or deprecation policy.
>
> Feel free to start a [discussion] to share thoughts or open [issues] for bugs
> and feature requests.

| Functions Framework | Unit Tests                                 | Lint Test                                  | Conformance Tests                                        |
| ------------------- | ------------------------------------------ | ------------------------------------------ | -------------------------------------------------------- |
| [Dart][ff_dart]     | [![][ff_dart_unit_img]][ff_dart_unit_link] | [![][ff_dart_lint_img]][ff_dart_lint_link] | [![][ff_dart_conformance_img]][ff_dart_conformance_link] |

An open source FaaS (Function as a Service) framework for writing portable Dart
functions, brought to you by the Google Dart and Cloud Functions teams.

The Functions Framework lets you write lightweight functions that run in many
different environments, including:

- Your local development machine
- [Google Cloud Run] - see [cloud run quickstart]
- [Google App Engine]
- [Knative]-based environments

[Google Cloud Functions] does not currently provide an officially supported Dart
language runtime, but we're working to make running on [Google Cloud Run] as
seamless and symmetric an experience as possible for your Dart Functions
Framework projects.

The framework allows you to go from:

[examples/hello/lib/functions.dart]

```dart
import 'package:shelf/shelf.dart';

Future<Response> function(Request request) async => Response.ok('Hello, World!');
```

To:

```shell
curl https://<your-app-url>
# Output: Hello, World!
```

All without needing to worry about writing an HTTP server or request handling
logic.

See more demos under the [examples] directory.

## Features

- Invoke a function in response to a request
- Automatically unmarshal events conforming to the [CloudEvents] spec
- Portable between serverless platforms

## Quickstart

From the [Dart quickstart] on your local machine:

```shell
$ cd examples/hello
$ docker build -t app .
...

$ docker run -it -p 8080:8080 --name demo --rm app
Listening on :8080
```

In another terminal:

```shell
$ curl localhost:8080
Hello, World!
```

See more [quickstarts].

## Contributing changes

See [`CONTRIBUTING.md`][contributing] for details on how to contribute to this
project, including how to build and test your changes as well as how to properly
format your code.

## Licensing

Apache 2.0; see [`LICENSE`][license] for details.

<!-- Repo links -->

[ff_dart]: https://github.com/GoogleCloudPlatform/functions-framework-dart

<!-- Unit Test links -->

[ff_dart_unit_img]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/workflows/Dart%20Unit%20CI/badge.svg
[ff_dart_unit_link]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/actions?query=workflow%3A"Dart+Unit+CI"

<!-- Lint Test links -->

[ff_dart_lint_img]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/workflows/Dart%20Lint%20CI/badge.svg
[ff_dart_lint_link]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/actions?query=workflow%3A"Dart+Lint+CI"

<!-- Conformance Test links -->

[ff_dart_conformance_img]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/workflows/Dart%20Conformance%20CI/badge.svg
[ff_dart_conformance_link]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/actions?query=workflow%3A"Dart+Conformance+CI"

<!-- Reference links -->

[cloudevents]: https://cloudevents.io/
[dart quickstart]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/blob/main/docs/quickstarts/01-quickstart-dart.md
[discussion]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/discussions
[examples]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/tree/main/examples
[examples/hello/lib/functions.dart]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/blob/main/examples/hello/lib/functions.dart
[google cloud run]:
  https://cloud.google.com/run/docs/quickstarts/build-and-deploy
[google app engine]: https://cloud.google.com/appengine/docs/go/
[google cloud functions]: https://cloud.google.com/functions/
[issues]: https://github.com/GoogleCloudPlatform/functions-framework-dart/issues
[knative]: https://github.com/knative/
[cloud run quickstart]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/blob/main/docs/quickstarts/03-quickstart-cloudrun.md
[quickstarts]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/tree/main/docs/quickstarts
[contributing]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/blob/main/CONTRIBUTING.md
[license]:
  https://github.com/GoogleCloudPlatform/functions-framework-dart/blob/main/functions_framework/LICENSE
