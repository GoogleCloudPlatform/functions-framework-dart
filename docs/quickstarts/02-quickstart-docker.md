# Quickstart: Docker

This quickstart discusses how to build and test a function using Docker on your
own machine.

You can use this approach if you don't have Dart installed or if you just want
to confirm your function is packaged correctly before deploying to a hosted
environment.

## Prerequisites

- [Docker] (Docker Desktop 3.x, Stable or Edge release)

## Get a copy of the `hello` example

You can either

- Run `dartfn` to create a new project using the `helloworld` generator (see
  [Installing and using dartfn])
- Clone this repo or download a [zip] archive and extract the contents
  - Change directory to `examples/hello`.

## Build a Docker image

The `docker run` command will use the `Dockerfile` in `examples/hello` to build
a Docker image for running containers.

> You can think of a Docker image as something like a binary package that
> contains a file system needed to launch containers, which are simply special
> processes on Linux that are isolated from the rest of the system (each
> container "thinks" it's running in its own computer).
>
> This file system is written in layers, and common layers can be shared across
> many different images you might have on your system, thus conserving a great
> deal of space. The way these layers are built have a one to one correspondence
> with each instruction in a `Dockerfile`. (As an interesting technical note,
> each instruction runs in _its_ own container while building the
> image).
>
> The idea of container isolation may sound like a virtual machine, but a key
> difference is that virtual machines include the entire operating system
> and need to "boot up"; containers must run on top of an existing operating
> system (generally just a Linux kernel or container-optimized operating
> system). Containers can launch essentially as fast as any other type of
> process, whereas virtual machines often take minutes to boot.
>
> The benefits of system isolation combined with the launch performance of
> regular processes, plus the universal packaging format of Docker images, are a
> big part of why containers have become so popular in the Cloud, where services
> generally need to scale very quickly in response to dynamic demand.

From the root of the `examples/hello` directory, create an image that tagged
(`-t`) with the name `hellofunc` using the current directory (`.`) for the build
context (the root of the files that will be copied into the image):

```shell
$ docker build -t hellofunc .
[+] Building 57.0s (17/17) FINISHED
 => [internal] load build definition from Dockerfile                                                                                 0.0s
 => => transferring dockerfile: 446B                                                                                                 0.0s
 => [internal] load .dockerignore                                                                                                    0.0s
 => => transferring context: 2B                                                                                                      0.0s
 => [internal] load metadata for docker.io/subfuzion/dart:slim                                                                       0.0s
 => [internal] load metadata for docker.io/google/dart:2.10                                                                          1.7s
 => [auth] google/dart:pull token for registry-1.docker.io                                                                           0.0s
 => [internal] load build context                                                                                                    1.0s
 => => transferring context: 69.50MB                                                                                                 1.0s
 => [stage-1 1/2] FROM docker.io/subfuzion/dart:slim                                                                                 0.0s
 => [stage-0 1/8] FROM docker.io/google/dart:2.10@sha256:ee2eace7c54696a43ba0f7db7ebeacf0b851d199cecd3bf4d7e3863a01dcbbf0            0.0s
 => CACHED [stage-0 2/8] WORKDIR /app                                                                                                0.0s
 => CACHED [stage-0 3/8] COPY pubspec.yaml /app/pubspec.yaml                                                                         0.0s
 => CACHED [stage-0 4/8] RUN dart pub get                                                                                            0.0s
 => [stage-0 5/8] COPY . .                                                                                                           0.2s
 => [stage-0 6/8] RUN dart pub get --offline                                                                                         1.2s
 => [stage-0 7/8] RUN dart pub run build_runner build --delete-conflicting-outputs                                                  46.4s
 => [stage-0 8/8] RUN dart compile exe bin/server.dart -o bin/server                                                                 6.4s
 => CACHED [stage-1 2/2] COPY --from=0 /app/bin/server /app/bin/server                                                               0.0s
 => exporting to image                                                                                                               0.0s
 => => exporting layers                                                                                                              0.0s
 => => writing image sha256:fb2a56b423ddbda916f71b7f53764d75667655b4d075cd9da8c5268332680455                                         0.0s
 => => naming to docker.io/library/hellofunc                                                                                         0.0s
```

The base image for the `hellofunc` has been heavily optimized so that it has
only the system dependencies necessary to provide support for a server application.
The function app itself is compiled as a native executable for Linux, so the
Dart VM isn't necessary at runtime.

If you're curious about the size of the image you created, enter:

```shell
$ docker image ls hellofunc
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
hellofunc    latest    12ec3cb36521   15 seconds ago   12MB
```

## Run the function in a Docker container

The following command will launch a container using `-p` to map the host
machine's port `8080` to port `8080` in the container. The `-it` combined flags
option effectively allows you to interact with the container from a terminal (
for example, to use `<Ctrl>-C` to terminate the running container). The `--rm`
option is used to automatically delete the terminated container from the system.

```shell
$ docker run -p 8080:8080 -it --rm hellofunc
Listening on :8080
```

You can access the function at `http://localhost:8080` from a browser or using
`curl`, as explained in the [previous quickstart](01-quickstart-dart.md).

## Changing the default port or function target

As described in the [previous quickstart](01-quickstart-dart.md), the
`PORT` environment variable or `--port` option can be used to override the
default port, and the `FUNCTION_TARGET` environment variable or `--target`
option can be used to override the default function.

However, with Docker you will need to specify environment variables differently
than previously shown:

### Change the default function

```shell
$ docker run -p 8080:8080 -it --rm -e FUNCTION_TARGET=handleGet hellofunc
...
```

You can also just use the `--target` argument instead (which is easier):

```shell
$ docker run -p 8080:8080 -it --rm hellofunc --target handleGet
...
```

### Using a different port on the host

If you need to select a different port on the host machine (perhaps
because `8080` is already in use), you only need to remap the
_host_ port to `8080` inside of the container:

```shell
$ docker run -p 9999:8080 -it --rm hellofunc
...
```

Now you can send requests from localhost to port `9999`:

```shell
$ curl http://localhost:9999
Hello, World!
```

Inside of the container, the server still listens on port `8080`.

### Change the default port inside the container

There shouldn't be any need to change the port that the function server listens
on **inside** of the container. Most hosting environments will set the
environment for container processes with `PORT` assigned to `8080`.

You can have multiple simultaneously running containers with processes listening
on port `8080` on the same host, as long as each container is mapped to a unique
host port (a unique port on localhost).

Nevertheless, if you really want to change the container port (the port that the
server binds to **inside** of the container) for some reason, you can do so as
shown below.

```shell
$ docker run -p 8080:9999 -it --rm -e PORT=9999 hellofunc
...
```

Note that both the `-p` port mapping has to be updated _and_ the environment
variable has to be set for the function server process listening in the
container.

Again, you also can use the `--port` argument (which is a bit easier)
instead of setting the environment variable:

```shell
$ docker run -p 8080:9999 -it --rm hellofunc --port 9999
...
```

In this scenario, you will still send requests to port `8080` on localhost:

```shell
$ curl http://localhost:8080
Hello, World!
```

## Clean up

When finished, clean up by entering:

```shell
docker image rm hellofunc   # remove the image
```

---

[[toc]](../README.md)
[[back]](01-quickstart-dart.md)
[[next]](03-quickstart-cloudrun.md)

<!-- reference links -->

[docker]: https://docs.docker.com/get-docker/
[installing and using dartfn]: 00-install-dartfn.md
[zip]:
https://github.com/GoogleCloudPlatform/functions-framework-dart/archive/main.zip
