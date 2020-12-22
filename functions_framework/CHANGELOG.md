# Changelog

## 0.3.0-dev

- Added support for functions that handle and return JSON data.
- Added support for defining and hosting Cloud Events.

- `functions_framework.dart`

  - Added `CloudEventHandler`, `CloudEventWithContextHandler`, and `CloudEvent`
    class to support Cloud Events.
  - Added `JsonHandler` and `JsonWithContextHandler` to support
    functions that handle and return JSON data.
  - Added `RequestLogger`, `LogSeverity`, and `HandlerWithLogger` to support
    logging from handlers.
  - `RequestContext` to get access to request headers, logging, and ability
    to set response headers for `CloudEvent` and custom handlers.
  - Added `BadRequestException` class. Functions can throw this exception to
    cause a `4xx` status code to be returned to a request source.

- `serve.dart`

  - Added `JsonFunctionTarget`, `JsonWithContextFunctionTarget`,
    and `BadRequestException` classes to support generated code for functions
    that handle and return JSON data.
  - Added `FunctionTarget` class. This is the abstract base class that wraps
    user written functions and links them to a name.
  - **BREAKING** The signature for `serve is now:`<br>
    `Future<void> serve(List<String> args, Set<FunctionTarget> targets)`

## 0.2.0

- **BREAKING** `CloudFunction` constructor parameters `target` is now named and
  optional. If not specified, it defaults to the name of the annotated function.
  (Previously, it defaulted to the string `'function'`.)
- Detect if running on Google Cloud and generate logs appropriately.
- Improved the error messages and exit codes for failures.
- Correctly respond with `404` with requests for `robots.txt` and `favicon.ico`.

## 0.1.0

This is a preview release of the Functions Framework for Dart to demonstrate
http functions support only (cloudevent support is not yet implemented). This
is a work in progress and currently does not pass conformance testing.
