# Installing and using dartfn

`dartfn` is a command-line (CLI) tool for working with Dart Functions Framework
projects. In this early version of the tool, you can use it to generate sample
projects from templates. Currently, there are three templates:

- helloworld - a basic HTTP handler function
- json - a simple function handler that accepts and sends JSON
- cloudevent - a simple cloudevent function handler

## Prerequisites

- [Dart SDK] v2.10+

## Install dartfn

To install `dartfn` on your machine, run the following command:

```shell
dart pub global activate dartfn
```

Output

```text
dart pub global activate functions_framework_tool
Resolving dependencies... (1.2s)
...
Precompiling executables... (1.1s)
Precompiled functions_framework_tool:dartfn.
Installed executable dartfn.
Activated functions_framework_tool 0.3.0.
```

## Using dartfn

### List available generators

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

### Generate a project

Generate a `helloworld` project, for example:

```shell
mkdir helloworld
cd helloworld
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

### Get the new project package dependencies

```shell
dart pub get
```

Output

```text
Resolving dependencies... (2.1s)
...
Changed 74 dependencies!
```

---

[[toc]](../README.md)
[[back]](../01-introduction.md)
[[next]](01-quickstart-dart.md)

<!-- reference links -->

[dart sdk]: https://dart.dev/get-dart
