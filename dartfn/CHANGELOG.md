# Changelog

## 0.4.2-dev

- Update templates to use `package:lints`.

## 0.4.1

- Require Dart 2.12
- Support the latest `package:json_serializable` in the JSON template.

## 0.4.0

- Updated templates for functions_framework 0.4.0

## 0.3.1

- Renamed the package to `dartfn` so `dart pub global activate dartfn` works.

## 0.3.0

The first version is `0.3.0` to align with the rest of published Functions
Framework packages. This package is intended to support tools for working with
Functions Framework projects. In this early iteration, a CLI tool (`dartfn`) is
provided with a `generate` command for scaffolding new projects into an empty
directory. Three initial generator templates are available (`helloworld`,
`json`, and `cloudevent`).
