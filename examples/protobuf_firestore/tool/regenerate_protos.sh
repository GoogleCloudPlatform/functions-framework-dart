#!/usr/bin/env bash

if [ ! -d "$GOOGLEAPIS" ]; then
  echo "Please set the GOOGLEAPIS environment variable to your clone of https://github.com/googleapis/googleapis."
  exit -1
fi

if [ ! -d "$GOOGLE_CLOUD_EVENTS" ]; then
  echo "Please set the GOOGLE_CLOUD_EVENTS environment variable to your clone of https://github.com/googleapis/google-cloudevents."
  exit -1
fi

protoc \
	-I$GOOGLEAPIS \
	-I$GOOGLE_CLOUD_EVENTS/proto \
	--dart_out="lib/src" \
	google/events/cloud/firestore/v1/data.proto \
	google/events/cloud/firestore/v1/events.proto \
	google/protobuf/struct.proto \
	google/protobuf/timestamp.proto \
	google/type/latlng.proto

dart format lib/src/google
