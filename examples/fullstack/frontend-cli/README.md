Call the demo greeting `backend` with a simple command-line app.

## Usage

A simple usage example:

With the `backend` running on `localhost:8080`

```shell
dart bin/greet.dart YOUR-NAME
```

With the `backend` hosted on another host (Cloud Run):

```shell
export GREETING_URL=https://greeting-EXAMPLE.run.app
dart bin/greet.dart YOUR-NAME
```

Activate the app locally so you can just run the `greet` command:

```shell
dart pub global activate --source path .
greet YOUR-NAME
```
