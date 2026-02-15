# google_cloud_e2e

End-to-end validation for the `google_cloud` package.

## Deploying

1.  Authenticate with Google Cloud:
    ```bash
    gcloud auth login
    ```

2.  Run the deploy script:
    ```bash
    ./tool/deploy_source.sh
    ```
    (Ensure you have `GCP_PROJECT`, `SERVICE_NAME`, `GCP_REGION` set if you don't want defaults)

## Running Validation

Once deployed, set the `E2E_URL` environment variable and run the tests:

```bash
export E2E_URL=https://your-service-url.run.app
dart test test/e2e_test.dart
```

## Running Locally

```bash
dart bin/server.dart
```
(Note: Some endpoints like `/sign` and `/project_id` might fail locally if not running in a GCE/Cloud Run environment with proper metadata server access, or they might fallback to local credentials if implemented that way.)
