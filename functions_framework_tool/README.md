# Functions Framework Tool package for Dart: dartfn

This package is intended to support tools for working with Functions Framework
projects.

In this early iteration, a CLI tool (`dartfn`) is provided with a `generate`
command for scaffolding new projects into an empty directory. Three initial
generator templates are available:

- helloworld - a basic HTTP handler function
- json - a simple function handler that accepts and sends JSON
- cloudevent - a simple cloudevent function handler

To install the `dartfn` tool on your machine, run the following command:

```shell
dart pub global activate dartfn
```

Run `dartfn` without any arguments to confirm it is installed.

```shell
dartfn is a tool for managing Dart Functions-as-a-Service (FaaS) projects.

Usage: dartfn <command> [arguments]

Global options:
-h, --help    Print this usage information.

Available commands:
  generate   Generate a project to get started.
  version    Print the current version.

Run "dartfn help <command>" for more information about a command.
```

## List available generators

```shell
dartfn generate --list
```

Output

```text
Available generators:
cloudevent - A sample Functions Framework project for handling a cloudevent.
helloworld - A sample "Hello, World!" Functions Framework project.
json       - A sample Functions Framework project for handling JSON.
```

If you want the generator list as JSON, use the hidden `--machine` flag:

```shell
dartfn generate --machine
```

Output

```json
[{"name":"cloudevent","label":"Dart Package","description":"A sample Functions Framework project for handling a cloudevent.","categories":["dart"],"entrypoint":"bin/server.dart"},{"name":"helloworld","label":"Dart Package","description":"A sample \"Hello, World!\" Functions Framework project.","categories":["dart"],"entrypoint":"bin/server.dart"},{"name":"json","label":"Dart Package","description":"A sample Functions Framework project for handling JSON.","categories":["dart"],"entrypoint":"bin/server.dart"}]
```

## Run a generator

```shell
mkdir demo
cd demo
dartfn generate helloworld
```

Output

```text
project: demo
Creating helloworld application `ex`:
  demo/.gitignore
  demo/Dockerfile
  demo/README.md
  demo/analysis_options.yaml
  demo/bin/server.dart
  demo/lib/functions.dart
  demo/pubspec.yaml
  demo/test/function_test.dart
8 files written.

--> to provision required packages, run 'pub get'
```

## Print the version and check for updates

```shell
dartfn version
```

Output

```text
Google Functions Framework for Dart CLI (dartfn) version: 0.3.1
```

If a newer version is available, the command will inform  you. Example:

```shell
dartfn version
```

Output (hypothetical update available)

```text
Google Functions Framework for Dart CLI (dartfn) version: 0.3.1
Version 0.3.2 is available! To update to this version, run: `pub global activate dartfn`.
```

If you just want the version number, use the `-s` or `--short` option:

```shell
dartfn version --short
```

Output

```text
0.3.1
```
