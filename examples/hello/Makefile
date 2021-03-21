# For illustrative and convenience purposes only; you don't have to use make,
# you can run the relevant dart commands directly.

.PHONY: clean

# bin/server.dart is the generated target for lib/functions.dart
bin/server.dart:
	dart run build_runner build --delete-conflicting-outputs

build: bin/server.dart

test: build
	dart test

run: build
	dart run bin/server.dart

clean:
	dart run build_runner clean
