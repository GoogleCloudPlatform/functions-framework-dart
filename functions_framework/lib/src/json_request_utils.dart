// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:gcp/gcp.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shelf/shelf.dart';

MediaType mediaTypeFromRequest(Request request, {String? requiredMimeType}) {
  final contentType = request.headers[contentTypeHeader];
  if (contentType == null) {
    throw BadRequestException(400, '$contentTypeHeader header is required.');
  }
  final MediaType value;
  try {
    value = MediaType.parse(contentType);
  } catch (e, stack) {
    throw BadRequestException(
      400,
      'Could not parse $contentTypeHeader header.',
      innerError: e,
      innerStack: stack,
    );
  }

  if (requiredMimeType != null) {
    if (value.mimeType != requiredMimeType) {
      // https://github.com/GoogleCloudPlatform/functions-framework#http-status-codes
      throw BadRequestException(
        400,
        'Unsupported encoding "${value.mimeType.toString()}". '
        'Only "$requiredMimeType" is supported.',
      );
    }
  }
  return value;
}

Future<Object?> decodeJson(Stream<List<int>> data) async {
  try {
    final value = await utf8.decoder.bind(data).transform(json.decoder).single;
    return value;
  } on FormatException catch (e, stackTrace) {
    // https://github.com/GoogleCloudPlatform/functions-framework#http-status-codes
    throw BadRequestException(
      400,
      'Could not parse the request body as JSON.',
      innerError: e,
      innerStack: stackTrace,
    );
  }
}

const jsonContentType = 'application/json';

enum SupportedContentTypes {
  json(jsonContentType),
  protobuf('application/protobuf');

  const SupportedContentTypes(this.value);

  final String value;

  static Future<({MediaType mimeType, Object? data})> decode(
    Request request,
  ) async {
    final type = mediaTypeFromRequest(request);
    final supportedType = SupportedContentTypes.values.singleWhere(
      (element) => element.value == type.mimeType,
      orElse: () => throw BadRequestException(
        400,
        'Unsupported encoding "$type". '
        'Supported types: '
        '${SupportedContentTypes.values.map((e) => '"${e.value}"').join(', ')}',
      ),
    );

    return (
      mimeType: type,
      data: await supportedType._decode(request.read()),
    );
  }

  Future<Object?> _decode(
    Stream<List<int>> data,
  ) async =>
      switch (this) {
        json => await decodeJson(data),
        protobuf => await data.fold<List<int>>(
            <int>[],
            (previous, element) => previous..addAll(element),
          ),
      };
}

const contentTypeHeader = 'Content-Type';
