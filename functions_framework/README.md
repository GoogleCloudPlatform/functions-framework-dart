# Functions Framework for Dart

> DISCLAIMER: this is not ready for production.

|Functions Framework|Unit Tests|Lint Test|Conformance Tests|
|---|---|---|---|
[Dart][ff_dart]| [![][ff_dart_unit_img]][ff_dart_unit_link] | [![][ff_dart_lint_img]][ff_dart_lint_link] | [![][ff_dart_conformance_img]][ff_dart_conformance_link] |

An open source FaaS (Function as a Service) framework for writing portable Dart
functions, brought to you by the Google Dart and Cloud Functions teams.

The Functions Framework lets you write lightweight functions that run in many
different environments, including:

- [Google Cloud Functions]
- Your local development machine
- [Knative]-based environments
- [Google App Engine]
- [Google Cloud Run]

The framework allows you to go from:

```dart
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction()
Response handleGet(Request request) => Response.ok('Hello, World!');
```

To:

```sh
curl http://my-url
# Output: Hello, World!
```

All without needing to worry about writing an HTTP server or request handling
logic.

## Features

- Build your Function in the same container environment used by Cloud Functions
  using [buildpacks](https://github.com/GoogleCloudPlatform/buildpacks).
- Invoke a function in response to a request
- Automatically unmarshal events conforming to the
  [CloudEvents](https://cloudevents.io/) spec
- Portable between serverless platforms

## Quickstart: Hello, World on your local machine

```shell
$ docker build -t app .
...

$ docker run -it -p 8080:8080 --name demo app
App listening on :8080
```

In another terminal...

```shell
$ curl localhost:8080
Hello, World!

```

## Contributing changes

See [`CONTRIBUTING.md`](../CONTRIBUTING.md) for details on how to contribute to
this project, including how to build and test your changes as well as how to
properly format your code.

## Licensing

BSD 3-Clause License. See [`LICENSE`](LICENSE) for details.

<!-- Reference links -->
[buildpacks]: https://github.com/GoogleCloudPlatform/buildpacks
[CloudEvents]: https://cloudevents.io/
[Google App Engine]: https://cloud.google.com/appengine/docs/go/
[Google Cloud Functions]: https://cloud.google.com/functions/
[Google Cloud Run]:
https://cloud.google.com/run/docs/quickstarts/build-and-deploy
[Knative]: https://github.com/knative/

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
