## 0.2.1-wip

- Add `projectIdFromCredentialsFile()` to automatically discover project ID from the credentials JSON file.
- Add `projectIdFromGcloudConfig()` to automatically discover project ID from gcloud CLI configuration.
- Add caching to `computeProjectId()` to avoid redundant discovery operations.
- Require `package:http` `^1.0.0`.
- Require Dart 3.9

## 0.2.0

- First release replacing `package:gcp`.
