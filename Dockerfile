################
FROM google/dart

WORKDIR /app
RUN dart pub global activate mono_repo 3.1.0-beta.4
COPY mono_repo.yaml /app/mono_repo.yaml
COPY functions_framework/mono_pkg.yaml /app/functions_framework/mono_pkg.yaml
COPY functions_framework/pubspec.yaml /app/functions_framework/pubspec.yaml
COPY functions_framework_builder/mono_pkg.yaml /app/functions_framework_builder/mono_pkg.yaml
COPY functions_framework_builder/pubspec.yaml /app/functions_framework_builder/pubspec.yaml
COPY test/hello/mono_pkg.yaml /app/test/hello/mono_pkg.yaml
COPY test/hello/pubspec.yaml /app/test/hello/pubspec.yaml
RUN mono_repo pub get
COPY . .
RUN mono_repo pub get --offline

WORKDIR /app/test/hello
RUN dart pub run build_runner build
RUN dart compile exe bin/main.dart -o bin/server

########################
FROM subfuzion/dart:slim
COPY --from=0 /app/test/hello/bin/server /app/bin/server
EXPOSE 8080
ENTRYPOINT ["/app/bin/server"]
