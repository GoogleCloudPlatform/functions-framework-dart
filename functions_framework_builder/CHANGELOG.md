## 0.4.11-wip

- Support the latest versions of `analyzer`, `dart_style` and `source_gen`.
- Require Dart 3.5

## 0.4.10

- Allow the latest `package:functions_framework`.

## 0.4.9

- Support the latest `package:analyzer`.

## 0.4.8

- Support the latest `package:analyzer`.
- Require Dart 3.0
- Support `package:http` v1

## 0.4.7

- Support the latest `package:analyzer`.

## 0.4.6

- Support the latest `package:analyzer`.

## 0.4.5

- Support the latest `package:analyzer`.

## 0.4.4

- Sort directives in generated `bin/server.dart`.

## 0.4.3

- Support the latest `package:analyzer`.

## 0.4.2

- Support classes with `toJson` methods defined via mix-in.
- Allow the latest `package:functions_framework`.

## 0.4.1

- Allow the latest version of `package:build_config`.

## 0.4.0

- Generate null-safe code.
- Migrate implementation to null safety.
- Support the latest `package:functions_framework` version.
- Allow the latest, null-safe versions of a number of packages.

## 0.3.1

- Support the latest `package:functions_framework` version.

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
