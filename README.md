# Functions Framework for Dart

> DISCLAIMER: This is not ready for production. Expect breaking changes.
> We're sharing our progress with the developer community and appreciate
> your feedback. Feel free to start a
> [discussion](https://github.com/GoogleCloudPlatform/functions-framework-dart/discussions)
> to share thoughts or open
> [issues](https://github.com/GoogleCloudPlatform/functions-framework-dart/issues)
> for bugs.

| Functions Framework | Unit Tests                                 | Lint Test                                  | Conformance Tests                                        |
| ------------------- | ------------------------------------------ | ------------------------------------------ | -------------------------------------------------------- |
| [Dart][ff_dart]     | [![][ff_dart_unit_img]][ff_dart_unit_link] | [![][ff_dart_lint_img]][ff_dart_lint_link] | [![][ff_dart_conformance_img]][ff_dart_conformance_link] |

An open source FaaS (Function as a Service) framework for writing portable Dart
functions, brought to you by the Google Dart and Cloud Functions teams.

The Functions Framework lets you write lightweight functions that run in many
different environments, including:

- Your local development machine
- [Google Cloud Run] - see [quickstart]
- [Google App Engine]
- [Knative]-based environments

[Google Cloud Functions] does not currently provide an officially supported Dart
language runtime, but we're working to make running on [Google Cloud Run] as
seamless and symmetric an experience as possible for your Dart Functions
Framework projects.

The framework allows you to go from:

[examples/hello/lib/functions.dart]

```dart
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction()
Response function(Request request) => Response.ok('Hello, World!');
```

To:

```shell
curl https://<your-app-url>
# Output: Hello, World!
```

All without needing to worry about writing an HTTP server or request
handling logic.

See more demos under the [examples] directory.

## Features

- Build your Function in the same container environment used by Cloud Functions
  using [buildpacks]
- Invoke a function in response to a request
- Automatically unmarshal events conforming to the [CloudEvents] spec
- Portable between serverless platforms

## Quickstart

[Dart quickstart] on your local machine.

```shell
$ cd examples/hello
$ docker build -t app .
...

$ docker run -it -p 8080:8080 --name demo --rm app
Listening on :8080
```

In another terminal...

```shell
$ curl localhost:8080
Hello, World!
```

See more [quickstarts].

## Contributing changes

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for details on how to contribute to
this project, including how to build and test your changes as well as how to
properly format your code.

## Licensing

Apache 2.0; see [`LICENSE`](LICENSE) for details.

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

[buildpacks]: https://github.com/GoogleCloudPlatform/buildpacks
[cloudevents]: https://cloudevents.io/
[dart quickstart]: docs/quickstarts/01-quickstart-dart.md
[docs]: docs
[examples]: examples
[examples/hello/lib/functions.dart]: examples/hello/lib/functions.dart
[google cloud run]:
https://cloud.google.com/run/docs/quickstarts/build-and-deploy
[google app engine]: https://cloud.google.com/appengine/docs/go/
[google cloud functions]: https://cloud.google.com/functions/
[knative]: https://github.com/knative/
[quickstart]: docs/quickstarts/03-quickstart-cloudrun.md
[quickstarts]: docs
