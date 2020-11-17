################
FROM google/dart

WORKDIR /app
RUN pub global activate mono_repo
COPY ./pubspec.yaml /app/pubspec.yaml
COPY mono_repo.yaml /app/mono_repo.yaml
COPY ./examples/hello/pubspec.yaml /app/examples/hello/pubspec.yaml
COPY ./examples/hello/mono_pkg.yaml /app/examples/hello/mono_pkg.yaml
RUN mono_repo pub get
COPY . .
RUN mono_repo pub get --offline

WORKDIR /app/examples/hello
RUN dart pub run build_runner build -o build

########################
FROM subfuzion/dart:slim
COPY --from=0 /usr/lib/dart/bin/dart /usr/lib/dart/bin/dart
COPY --from=0 /app/examples/hello/build/bin/main.vm.app.dill /app/bin/server.dill
EXPOSE 8080
ENTRYPOINT ["/usr/lib/dart/bin/dart", "/app/bin/server.dill"]
