# 0.3.0-dev

- Added support for functions that handle and return JSON data.
- Added support for defining and hosting Cloud Events.

- `functions_framework.dart`

  - Added `typedef CustomEventHandler` to support functions that handle and
    return JSON data.
  - Added `typedef CloudEventHandler` and `CloudEvent` class to support
    Cloud Events.
  - Added the top-level `logger` property which exposes the new `CloudLogger`
    class. Severity is expressed in terms of the new `LogSeverity` class.
  - Added `BadRequestException` class. Functions can throw this exception to
    cause a `4xx` status code to be returned to a request source.

- `serve.dart`

  - Added `CustomTypeFunctionEndPoint`, `VoidCustomTypeFunctionEndPoint`, and
    `BadRequestException` classes to support generated code for functions that
    handle and return JSON data.
  - Added `FunctionEndpoint` class.
  - **BREAKING** The signature for `serve is now:`<br>
    `Future<void> serve(List<String> args, Set<FunctionEndpoint> functions)`

# 0.2.0

- **BREAKING** `CloudFunction` constructor parameters `target` is now named and
  optional. If not specified, it defaults to the name of the annotated function.
  (Previously, it defaulted to the string `'function'`.)
- Detect if running on Google Cloud and generate logs appropriately.
- Improved the error messages and exit codes for failures.
- Correctly respond with `404` with requests for `robots.txt` and `favicon.ico`.

# 0.1.0 - 2020-11-23

This is a preview release of the Functions Framework for Dart to demonstrate
http functions support only (cloudevent support is not yet implemented). This
is a work in progress and currently does not pass conformance testing.
