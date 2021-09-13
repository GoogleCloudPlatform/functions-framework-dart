# Official Dart image: https://hub.docker.com/_/dart
# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.14)
FROM dart:stable AS build

# resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# copy app source code and aot compile it.
COPY . .
# ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart pub run build_runner build --delete-conflicting-outputs
RUN dart compile exe bin/server.dart -o bin/server

# build minimal serving image from aot-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

# start server.
EXPOSE 8080
ENTRYPOINT ["/app/bin/server", "--signature-type=cloudevent"]
