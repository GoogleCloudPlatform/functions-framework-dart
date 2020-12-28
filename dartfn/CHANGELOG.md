# Changelog

## 0.3.2

- Fix exception on Windows due to SIGTERM handler ([PR #153]).

## 0.3.1

- Renamed the package to `dartfn` so `dart pub global activate dartfn` works.

## 0.3.0

The first version is `0.3.0` to align with the rest of published Functions
Framework packages. This package is intended to support tools for working with
Functions Framework projects. In this early iteration, a CLI tool (`dartfn`) is
provided with a `generate` command for scaffolding new projects into an empty
directory. Three initial generator templates are available (`helloworld`,
`json`, and `cloudevent`).

<!-- Reference links -->
[pr #153]:
https://github.com/GoogleCloudPlatform/functions-framework-dart/issues/151
