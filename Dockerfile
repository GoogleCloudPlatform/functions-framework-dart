################
FROM google/dart

WORKDIR /app
RUN pub global activate mono_repo
COPY mono_repo.yaml /app/mono_repo.yaml
COPY functions_framework/mono_pkg.yaml /app/functions_framework/mono_pkg.yaml
COPY functions_framework/pubspec.yaml /app/functions_framework/pubspec.yaml
COPY functions_framework_builder/mono_pkg.yaml /app/functions_framework_builder/mono_pkg.yaml
COPY functions_framework_builder/pubspec.yaml /app/functions_framework_builder/pubspec.yaml
COPY examples/hello/mono_pkg.yaml /app/examples/hello/mono_pkg.yaml
COPY examples/hello/pubspec.yaml /app/examples/hello/pubspec.yaml
RUN mono_repo pub get
COPY . .
RUN mono_repo pub get --offline

WORKDIR /app/examples/hello
RUN dart pub run build_runner build --delete-conflicting-outputs -o build
RUN dart compile exe bin/main.dart -o bin/server

########################
FROM subfuzion/dart:slim
COPY --from=0 /app/examples/hello/bin/server /app/bin/server
EXPOSE 8080
ENTRYPOINT ["/app/bin/server"]
