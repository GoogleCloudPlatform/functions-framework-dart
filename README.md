# Functions Framework for Dart

An open source FaaS (Function as a Service) framework for writing portable Dart functions,
brought to you by the Google Dart and Cloud Functions teams.

The Functions Framework lets you write lightweight functions that run in many
different environments, including:

*   [Google Cloud Functions](https://cloud.google.com/functions/)
*   Your local development machine
*   [Knative](https://github.com/knative/)-based environments
*   [Google App Engine](https://cloud.google.com/appengine/docs/go/)
*   [Google Cloud Run](https://cloud.google.com/run/docs/quickstarts/build-and-deploy)

The framework allows you to go from:

```dart
@function
library app;

import 'package:functions_framework_dart/functions_framework.dart';
import 'package:shelf/shelf.dart';

Response handleGet(Request request) => Response.ok('Hello, World!');
```

To:

```sh
curl http://my-url
# Output: Hello, World!
```

All without needing to worry about writing an HTTP server or request
handling logic.

## Features

*   Build your Function in the same container environment used by Cloud Functions using [buildpacks](https://github.com/GoogleCloudPlatform/buildpacks).
*   Invoke a function in response to a request
*   Automatically unmarshal events conforming to the
    [CloudEvents](https://cloudevents.io/) spec
*   Portable between serverless platforms

## Quickstart: Hello, World on your local machine
...

*Dev quickstart - not for production*

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
