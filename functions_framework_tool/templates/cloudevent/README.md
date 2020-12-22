# Basic CloudEvent example

This example demonstrates writing a function to handle a CloudEvent.

CloudEvent function handlers don't return a response to send to the event
producter. They generally perform some work and print output for logging.

The basic shape of the function handler looks like this:

```dart
@CloudFunction()
void function(CloudEvent event, RequestContext context) {
}
```

Or like this if it needs to perform work that will complete sometime in the
future:

```dart
@CloudFunction()
FutureOr<void> function(CloudEvent event, RequestContext context) async {
}
```

The full code of the function for this example is shown below:

`lib/functions.dart`

```dart
import 'dart:convert';
import 'dart:io';

import 'package:functions_framework/functions_framework.dart';

const _encoder = JsonEncoder.withIndent(' ');

@CloudFunction()
void function(CloudEvent event, RequestContext context) {
  context.logger.info('event subject: ${event.subject}');
  stderr.writeln(_encoder.convert(event));
}
```

All the function does is log the source and subject of the CloudEvent that
triggered it, and then prints out the entire event JSON object for informational
purposes.

## Generate project files

The Dart `build_runner` tool generates `bin/server.dart`, the main entry point
for the function server app, which invokes the function in `lib/functions.dart`.

Run the `build_runner` tool, as shown here:

```shell
$ dart run build_runner build
[INFO] Generating build script completed, took 337ms
[INFO] Reading cached asset graph completed, took 48ms
[INFO] Checking for updates since last build completed, took 426ms
[INFO] Running build completed, took 13ms
[INFO] Caching finalized dependency graph completed, took 29ms
[INFO] Succeeded after 51ms with 0 outputs (0 actions)
```

## Test the function

```shell
$ dart test
00:02 +1: All tests passed!
```

## Run the function

The default signature type for a function is for handling normal HTTP requests.
When running a function for handling a cloudevent, you must either set
the `FUNCTION_SIGNATURE_TYPE` environment variable or the
`--signature-type` command line option to `cloudevent`, as shown below:

```shell
$ dart run bin/server.dart --signature-type cloudevent
Listening on :8080
```

From another terminal, trigger the CloudEvent by posting event data:

```shell
$ curl --data-binary @sample/data.json -H 'content-type: application/json' -w '%{http_code}\n' localhost:8080
200
```

Tools like [curl] (and [postman]) are good for sending HTTP requests. The
options used in this example are:

- `--data-binary @sample/data.json` - set the request body to a JSON document
  read from the file `sample/data.json`
- `-H "content-type: application/json"` - set an HTTP header to indicate that
  the body is a JSON document
- `-w '%{http_code}\n'` - print the HTTP status code (expect 200 for success)

Alternatively, instead of running `curl`, you can run either of the following
Dart scripts examples under the `examples/raw_cloudevent/tool` directory:

- `dart run tool/binary_mode_request.dart`
- `dart run tool/structured_mode_request.dart`

For more details on getting started or to see how to run the function locally on
Docker or deploy to Cloud Run, see these quick start guides:

- [Quickstart: Dart]
- [Quickstart: Docker]
- [Quickstart: Cloud Run]

<!-- reference links -->
[curl]: https://curl.se/docs/manual.html
[Quickstart: Dart]: https://github.com/GoogleCloudPlatform/functions-framework-dart/blob/main/docs/quickstarts/01-quickstart-dart.md
[Quickstart: Docker]: https://github.com/GoogleCloudPlatform/functions-framework-dart/blob/main/docs/quickstarts/02-quickstart-docker.md
[Quickstart: Cloud Run]: https://github.com/GoogleCloudPlatform/functions-framework-dart/blob/main/docs/quickstarts/03-quickstart-cloudrun.md
[postman]: https://www.postman.com/product/api-client/
