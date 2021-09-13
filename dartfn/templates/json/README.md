# JSON example

This example demonstrates writing a function that accepts and returns JSON.

The basic shape of the function handler looks like this:

```dart
@CloudFunction()
GreetingResponse function(GreetingRequest request) {
}
```

The client will send a JSON document using the HTTP POST method. Here's an
example request:

```json
{
  "name": "World"
}
```

The function will send a JSON document as the response. Here's an example
response after receiving the above request:

```json
{
  "salutation": "Hello",
  "name": "World"
}
```

The Functions Framework parses the request data to fit the shape of a
`GreetingRequest` object for you. Because a name might not have been sent with
the request, the function implementation provides a default name: `World`.

```dart
@CloudFunction()
GreetingResponse function(GreetingRequest request) {
  final name = request.name ?? 'World';
}
```

Finally, the function creates an object returns it. The Functions Framework will
take this and attempt "do the right" thing. In this case, the function is typed
to return a `FutureOr<GreetingResponse>`, which has a `toJson()` method, so the
framework will invoke this, then set the response body to the stringified result
and set the response header (`content-type`) to `application/json`).

```dart
@CloudFunction()
GreetingResponse function(Map<String, dynamic> request) {
  final name = request['name'] as String ?? 'World';
  final json = GreetingResponse(salutation: 'Hello', name: name);
  return json;
}
```

The full code is shown below:

lib/functions.dart

```dart
import 'dart:async';

import 'package:functions_framework/functions_framework.dart';
import 'package:json_annotation/json_annotation.dart';

part 'functions.g.dart';

@JsonSerializable()
class GreetingRequest {
  final String? name;

  GreetingRequest({this.name});

// This class also includes two marshalling methods that are
// standard boilerplate that depend on generated code in 'functions.g.dart'

// To help with testing, this class also overrides the equality (`==`)
// operator, and therefore also `hashCode`.
}

@JsonSerializable()
class GreetingResponse {
  final String salutation;
  final String name;

  GreetingResponse({required this.salutation, required this.name});

// This  class also includes two marshalling methods that are
// standard boilerplate that depend on generated code in 'functions.g.dart'

// To help with testing, this class also overrides the equality (`==`)
// operator, and therefore also `hashCode`.
}

@CloudFunction()
GreetingResponse function(GreetingRequest request) {
  final name = request.name ?? 'World';
  final json = GreetingResponse(salutation: 'Hello', name: name);
  return json;
}
```

## Generate project files

The Dart `build_runner` tool generates the following files

- `lib/functions.g.dart` - the part file for `GreetingResponse` serialization
- `bin/server.dart` - the main entry point for the function server app, which
  invokes the function

Run the `build_runner` tool, as shown here:

```shell
$ dart run build_runner build
[INFO] Generating build script completed, took 337ms
[INFO] Reading cached asset graph completed, took 48ms
[INFO] Checking for updates since last build completed, took 426ms
[INFO] Running build completed, took 13ms
[INFO] Caching finalized dependency graph completed, took 29ms
[INFO] Succeeded after 51ms with 0 outputs (0 actions)
```

## Test the function

```shell
$ dart test
00:02 +1: All tests passed!
```

## Run the function

```shell
$ dart run bin/server.dart
Listening on :8080
```

From another terminal, send a JSON request:

```shell
$ curl -X POST -H "content-type: application/json" -d '{ "name": "World" }' -i localhost:8080
HTTP/1.1 200 OK
date: Sat, 19 Dec 2020 02:17:42 GMT
content-length: 37
x-frame-options: SAMEORIGIN
content-type: application/json
x-xss-protection: 1; mode=block
x-content-type-options: nosniff
server: dart:io with Shelf

{"salutation":"Hello","name":"World"}
```

Tools like [curl] (and [postman]) are good for sending HTTP requests. The
options used in this example are:

- `-X POST` - send an HTTP POST request
- `-H "content-type: application/json"` - set an HTTP header to indicate that
  the body is a JSON document
- `-d '{ "name": "World" }'` - set the request body to a JSON document
- `-i` - show the response headers (to confirm the response body content type is
  also a JSON document)

The last line, separated by a blank line, prints the response body.

For more details on getting started or to see how to run the function locally on
Docker or deploy to Cloud Run, see these quick start guides:

- [Quickstart: Dart]
- [Quickstart: Docker]
- [Quickstart: Cloud Run]

<!-- reference links -->
[curl]: https://curl.se/docs/manual.html
[Quickstart: Dart]: https://github.com/GoogleCloudPlatform/functions-framework-dart/blob/main/docs/quickstarts/01-quickstart-dart.md
[Quickstart: Docker]: https://github.com/GoogleCloudPlatform/functions-framework-dart/blob/main/docs/quickstarts/02-quickstart-docker.md
[Quickstart: Cloud Run]: https://github.com/GoogleCloudPlatform/functions-framework-dart/blob/main/docs/quickstarts/03-quickstart-cloudrun.md
[postman]: https://www.postman.com/product/api-client/
