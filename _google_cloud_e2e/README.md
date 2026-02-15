# google_cloud_e2e

End-to-end validation for the `google_cloud` package.

## Running E2E Tests

1.  Authenticate with Google Cloud:
    ```bash
    gcloud auth login
    ```

2.  Run the E2E script:
    ```bash
    dart tool/run_e2e.dart
    ```
    (Ensure you have `GCP_PROJECT`, `SERVICE_NAME`, `GCP_REGION` set in `.dart_tool/credentials.yaml` or as environment variables if you don't want defaults)

    This script will:
    - Build the server as a Linux executable.
    - Deploy it to Cloud Run.
    - Run the tests against the deployed URL.

## Running Locally

```bash
dart bin/server.dart
```
(Note: Some endpoints like `/sign` and `/project_id` might fail locally if not running in a GCE/Cloud Run environment with proper metadata server access, or they might fallback to local credentials if implemented that way.)
