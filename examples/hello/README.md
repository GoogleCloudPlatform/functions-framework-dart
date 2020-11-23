# Hello world example

This example handles HTTP GET requests by responding with 'Hello, World!'.

##### lib/app.dart
```dart
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';

@CloudFunction()
Response handleGet(Request request) => Response.ok('Hello, World!');
```

You can run this example on your own machine using Docker:

```shell
$ docker build -t hello .
...

$ docker run -it -p 8080:8080 --name app hello
App listening on :8080
```

From another terminal:

```shell
curl http://localhost:8080
Hello, World!
```

If you want to see the size of the image you created, enter:

```shell
$ docker image ls hello
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
hello        latest    3f23c737877b   1 minute ago     11.6MB
```

When finished, clean up by entering:

```shell
$ docker rm -f app        # remove the container
$ docker image rm hello   # remove the image
```