# backend

This is the Dart function app that provides the backend for the Dart full-stack
demo.

The backend demonstrates writing a function that accepts and returns JSON.

The function handler looks like this:

```dart
@CloudFunction()
GreetingResponse function(GreetingRequest request) {
  final name = request.name ?? 'World';
  final json = GreetingResponse(salutation: getSalutation(), name: name);
  return json;
}
```

A client sends a JSON document using the HTTP POST method. Here's an example
request body:

```json
{
  "name": "World"
}
```

The function will send a JSON document as the response. Here's an example
response body after handling the above request:

```json
{
  "salutation": "Hello",
  "name": "World"
}
```

Given the shape of the function, the Functions Framework parses the request
body as a GreetingRequest, and serializes the GreetingResponse for the response
body and sets the response header (`content-type`) to `application/json`).

## Generate project files

The Dart `build_runner` tool generates the following files

- `lib/api_types.g.dart` - the part file for `GreetingRequest` and
  `GreetingResponse` serialization
- `bin/server.dart` - the main entry point for the function server app, which
  invokes the function at `lib/functions.dart`

Run the `build_runner` tool, as shown here:

```shell
dart run build_runner build --delete-conflicting-outputs
```

Output
```text
[INFO] Generating build script completed, took 337ms
[INFO] Reading cached asset graph completed, took 48ms
[INFO] Checking for updates since last build completed, took 426ms
[INFO] Running build completed, took 13ms
[INFO] Caching finalized dependency graph completed, took 29ms
[INFO] Succeeded after 51ms with 0 outputs (0 actions)
```

## Test the function

```shell
dart test
```

Output
```text
00:02 +1: All tests passed!
```

## Run the function

```shell
dart run bin/server.dart
```

Output
```text
Listening on :8080
```

From another terminal, send a JSON request:

```shell
curl -X POST -H "content-type: application/json" \
  -d '{ "name": "World" }' -i -w "\n" localhost:8080
```

Output
```text
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
- `-w "\n"` - appends a newline to the output for easier reading

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
