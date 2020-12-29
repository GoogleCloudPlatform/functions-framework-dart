# Changelog

## 0.3.1-dev

## 0.3.0

- Added support for connecting functions that handle and return JSON data.
- Added support for connecting functions that handle the `CloudEvent` type.
- Support `analyzer: '>=0.40.6 <0.42.0'`

## 0.2.0

- **BREAKING** Function definitions now must be in `lib/functions.dart`.
- **BREAKING** Generated server binary is now `bin/server.dart` instead of
  `bin/main.dart`.
- Add a number of checks to the builder to make sure the annotations are used
  on the correct type of functions.
- Renamed the builder library from `functions_framework_builder.dart` to
  `builder.dart`. This is the convention for builders. This is potentially
  breaking for anyone why imports this library – but that's not expected.
- Hid the `FunctionsFrameworkGenerator` class. Not meant for external
  consumption.

## 0.1.0

This is a preview release of the Functions Framework Builder package for Dart to
demonstrate http functions support only (cloudevent support is not yet
implemented). This is a work in progress and currently does not pass conformance
testing.
