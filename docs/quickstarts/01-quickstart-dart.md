# Quickstart: Dart

This quickstart discusses how to build and test a function locally as part of a
normal developer workflow.

## Prerequisites

- [Dart SDK] v2.10+
- Optional: [curl]

## Get a copy of the `hello` example

You can either

- Run `dartfn` to create a new project using the `helloworld` generator (see
  [Installing and using dartfn])
- Clone this repo or download a [zip] archive and extract the contents
  - Change directory to `examples/hello`.

## Build the example

The Functions Framework generates code based on the function you write in
`lib/functions.dart` to create a complete server for listening to HTTP and
CloudEvent requests. The output of this build process is `bin/server.dart`.

To generate the `bin/server.dart`, you need to run the Dart `build_runner` tool.

```shell
$ dart run build_runner build --delete-conflicting-outputs
[INFO] Generating build script completed, took 304ms
[INFO] Reading cached asset graph completed, took 46ms
[INFO] Checking for updates since last build completed, took 412ms
[INFO] Running build completed, took 2.2s
[INFO] Caching finalized dependency graph completed, took 28ms
[INFO] Succeeded after 2.3s with 1 outputs (1 actions)

```

## Test the build

A test (`test/function_test.dart`) is provided as a simple example for testing
your function now that it has been built. You can run this test from the root
of `examples/hello`.

```shell
$ dart test
00:02 +1: All tests passed!
```

## Run the function

Use the `dart run` command to run your function. The code in
`lib/functions.dart` implements the function logic, but the function app entry
point is the file that was generated during the build process
(`bin/server.dart`).

```shell
$ dart run bin/server.dart
Listening on :8080
```

You can test the function on `http://localhost:8080` using your browser or from
another terminal using [curl].

```shell
$ curl http://localhost:8080
Hello, World!
```

### Run the function with a different port

The specification for Functions Frameworks requires that the function app
listens on the port set by the PORT environment variable.

The Functions Framework for Dart automatically checks this environment variable
for you so that the server listens to the correct port; if PORT isn't set, then
the default listening port is `8080`.

You can set a port explicitly from the command-line like this:

```shell
$ PORT=9090 dart run bin/server.dart
Listening on :9090
```

As a convenience, the function server will also accept a `--port` option, as
shown here:

```shell
$ dart run bin/server.dart --port 8888
Listening on :8888
```

If you specify both, the `--port` option will override the `PORT`
environment variable.

### Stopping the function

The function server responds to both the `SIGTERM` and `SIGINT` signals.
`SIGTERM` is used by hosting environments and by tests to attempt a graceful
shutdown. `SIGINT` can be used by pressing `<Ctrl>-C` in the terminal running
the function server. This is indicated below as `^C`.

```shell
$ dart run bin/server.dart
Listening on :8080
^CReceived signal SIGINT - closing
```

## Modifying the function implementation

The Functions Framework for Dart provides a wrapper over the [Shelf] web server
framework. While you do not need to set up the server yourself, you should be
aware of the Shelf [Request] and [Response] classes.

> These docs and the framework itself are an evolving work in progress.
> The docs will be expanded to including more examples and details for setting
> HTTP response headers and returning structured JSON data.

## Changing the default function name

If you would like to rename the handler function (`function`) to something else
more descriptive (ex: `handleGet`), you need to ensure that
the `FUNCTION_TARGET` environment variable is set to the new function name.

For example:

```dart
@CloudFunction()
Response handleGet(Request request) => Response.ok('Hello, World!');
```

Run `build_runner` to regenerate `bin/server.dart` from `lib/functions.dart`

```shell
$ dart run build_runner build
...
```

Run tests to confirm the build still works. Note that `FUNCTION_TARGET` must now
be explicitly set for the test process:

```shell
$ FUNCTION_TARGET=handleGet dart test
00:02 +1: All tests passed!
```

You will also have to explicitly set `FUNCTION_TARGET` to run the function:

```shell
$ FUNCTION_TARGET=handleGet dart run bin/server.dart
Listening on :8080
```

You can use the `--target` command-line argument to override
`FUNCTION_TARGET`, similar to using the `--port` command-line argument to
override `PORT`:

```shell
$ dart run bin/server.dart --target handleGet
Listening on :8080
```

---

[[toc]](../README.md)
[[back]](00-install-dartfn.md)
[[next]](02-quickstart-docker.md)

<!-- reference links -->

[curl]: https://curl.se/docs/manual.html
[dart sdk]: https://dart.dev/get-dart
[installing and using dartfn]: 00-install-dartfn.md
[request]: https://pub.dev/documentation/shelf/latest/shelf/Request-class.html
[response]: https://pub.dev/documentation/shelf/latest/shelf/Response-class.html
[shelf]: https://pub.dev/packages/shelf
[zip]: https://github.com/GoogleCloudPlatform/functions-framework-dart/archive/main.zip
