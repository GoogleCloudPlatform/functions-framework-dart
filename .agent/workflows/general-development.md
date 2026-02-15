---
description: General guidelines to follow when working in this repository
---


This document outlines the workflows and standards for contributing to `functions-framework-dart`.

## Project Structure
This is a monorepo managed with **Melos** and Dart **Workspaces**.
- `functions_framework`: The core framework package.
- `functions_framework_builder`: Code generation support.
- `examples/`: Various sample functions.
- `integration_test/`: End-to-end tests for the framework.
- `google_cloud/`: Shared utilities for Google Cloud environment detection
  and authentication.

## Development Workflow

### 1. Setup
Ensure you have the latest Dart SDK.
```bash
dart pub get
```

### 2. Making Changes
- **Core Logic**: Modify `functions_framework/lib/`.
- **Builder Logic**: Modify `functions_framework_builder/lib/`.
- **GCP Utilities**: Modify `google_cloud/lib/`.
- **Tests**: ALWAYS add unit tests in the respective package's `test/` directory.

### 3. mono_repo
If you update the SDK constraints, run `mono_repo generate` to regenerate the 
github workflows.

### 4. Running Tests Manually
You can run tests for a specific package:
```bash
cd functions_framework
dart test
```

### 5. melos

If you modify files that require code generation (e.g. `json_serializable`),
run:
```bash
melos run build:all
```
This ensures all generated files are up-to-date across the workspace.

### 6. releases and changelogs and such

- **Versioning**:
  - `pubspec.yaml` version and `CHANGELOG.md` version must sync.
  - Use a `-wip` suffix (e.g., `0.4.4-wip`) for versions under development.
- **Verification**:
  - Check published versions on pub.dev - you can see the latest version at
    https://pub.dev/api/packages/[pkg_name]
  - Verify git tags match the format `pkg_name-vSEMVER` (e.g.,
    `functions_framework-v0.4.0`).
- **Changelog**:
  - Update `CHANGELOG.md` when making public API changes.
  - Highlight **Breaking Changes**, **New Features**, and **Bug Fixes**.
  - Review the git diff since the last release to ensure all changes are captured.

### 7. using pkg:google_cloud constants.dart

- Always `import 'package:google_cloud/constants.dart' as cloud_constants;`

### 8. update THIS FILE as you learn things

- This file is my primary source of truth for project-specific context.
- If you discover a new pattern, "gotcha", or workflow, please ask me to
  "update the dev docs" so I don't make the same mistake twice!

## Coding Standards
- **Linting**: We use strict rules from `dart_flutter_team_lints`.
  - Run `dart analyze` to check for issues.
  - Pay extra attention to long lines! 80 line limit is required.
    - this includes markdown files!
- **Formatting**: All code must be formatted with `dart format`.
- **Typing**: Avoid `dynamic`. Use strong types.

## Key Technologies
- **Shelf**: The underlying server abstraction.
- **CloudEvents**: For event-driven functions.
- **Build Runner**: Used for generating code (e.g., `json_serializable`).
  - Run `dart run build_runner build` if you modify generated files.
  - Or the melos command: `melos run build:all`
