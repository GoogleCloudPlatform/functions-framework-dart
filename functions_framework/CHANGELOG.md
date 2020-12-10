# 0.2.0-dev

- **BREAKING** `CloudFunction` constructor paramaters `target` is now named and
  optional. If not specified, it defaults to the name of the annotated function.
  (Previously, it defaulted to the string `'function'`.)
- Detect if running on Google Cloud and generate logs appropriately.
- Improved the error messages and exit codes for failures.
- Correctly respond with `404` with requests for `robots.txt` and `favicon.ico`.

# 0.1.0 - 2020-11-23

This is a preview release of the Functions Framework for Dart to demonstrate
http functions support only (cloudevent support is not yet implemented). This 
is a work in progress and currently does not pass conformance testing.
