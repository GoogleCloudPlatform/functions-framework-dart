.PHONY: clean

FUNCTION_TARGET = function
PORT = 8080

gen:
	dart run build_runner build --delete-conflicting-outputs

build: gen

test: clean build
	dart test

clean:
	dart run build_runner clean
	rm -rf bin/server*.dart

run: build
	dart run bin/server_$(FUNCTION_TARGET).dart --port=$(PORT)
