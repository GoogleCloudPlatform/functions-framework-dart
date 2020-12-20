# Functions Framework for Dart

> DISCLAIMER: This is not ready for production. Expect breaking changes.
> We're sharing our progress with the developer community and appreciate
> your feedback. Feel free to start a
> [discussion](https://github.com/GoogleCloudPlatform/functions-framework-dart/discussions)
> to share thoughts or open
> [issues](https://github.com/GoogleCloudPlatform/functions-framework-dart/issues)
> for bugs.

|Functions Framework|Unit Tests|Lint Test|Conformance Tests|
|---|---|---|---|
[Dart][ff_dart]| [![][ff_dart_unit_img]][ff_dart_unit_link] | [![][ff_dart_lint_img]][ff_dart_lint_link] | [![][ff_dart_conformance_img]][ff_dart_conformance_link] |

An open source FaaS (Function as a Service) framework for writing portable Dart functions,
brought to you by the Google Dart and Cloud Functions teams.

The Functions Framework lets you write lightweight functions that run in many
different environments, including:

- [Google Cloud Functions](https://cloud.google.com/functions/)
- Your local development machine
- [Knative](https://github.com/knative/)-based environments
- [Google App Engine](https://cloud.google.com/appengine/docs/go/)
- [Google Cloud Run](https://cloud.google.com/run/docs/quickstarts/build-and-deploy)

The framework allows you to go from:

```dart
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction()
Response function(Request request) => Response.ok('Hello, World!');
```

To:

```shell
curl https://example.com
# Output: Hello, World!
```

All without needing to worry about writing an HTTP server or request
handling logic.

See the [Hello, World!](examples/hello/lib/functions.dart) demo in the
`examples/hello` directory.

## Features

- Build your Function in the same container environment used by Cloud
  Functions using [buildpacks](https://github.com/GoogleCloudPlatform/buildpacks).
- Invoke a function in response to a request
- Automatically unmarshal events conforming to the
  [CloudEvents](https://cloudevents.io/) spec
- Portable between serverless platforms

## Quickstart

"Hello, World" on your local machine.

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

See the [docs] for more quickstarts.

## Contributing changes

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for details on how to contribute to
this project, including how to build and test your changes as well as how to
properly format your code.

## Licensing

Apache 2.0; see [`LICENSE`](LICENSE) for details.

<!-- Repo links -->
[docs]: docs
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
