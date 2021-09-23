# Official Dart image: https://hub.docker.com/_/dart
# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

# cache deps
WORKDIR /app
COPY ./functions_framework/pubspec.yaml /app/functions_framework/
COPY ./functions_framework_builder/pubspec.yaml /app/functions_framework_builder/
COPY ./integration_test/pubspec.yaml /app/integration_test/

WORKDIR /app/integration_test
RUN dart pub get

# As long as pubspecs haven't changed, all deps should be cached and only
# new image layers from here on need to get rebuild for modified sources.
COPY . ..
RUN dart pub get --offline

RUN dart pub run build_runner build --delete-conflicting-outputs
RUN dart compile exe bin/server.dart -o bin/server

########################
FROM scratch
COPY --from=0 /app/integration_test/bin/server /app/bin/server
EXPOSE 8080
ENTRYPOINT ["/app/bin/server"]
