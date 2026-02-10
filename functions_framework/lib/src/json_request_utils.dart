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
import 'dart:typed_data';

import 'package:google_cloud/google_cloud.dart';
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

extension RequestExt on Request {
  Future<List<int>> readBytes() async {
    final length = contentLength;
    if (length == null) {
      return await read().fold<List<int>>(
        <int>[],
        (previous, element) => previous..addAll(element),
      );
    }
    final bytes = Uint8List(length);
    var offset = 0;
    await for (var bits in read()) {
      bytes.setAll(offset, bits);
      offset += bits.length;
    }
    return bytes;
  }

  Future<Object?> decodeJson() async {
    try {
      final value = await (encoding ?? utf8).decoder
          .bind(read())
          .transform(json.decoder)
          .single;
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

  Future<({MediaType mimeType, Object? data})> decode() async {
    final type = mediaTypeFromRequest(this);
    final supportedType = SupportedContentTypes.values.singleWhere(
      (element) => element.value == type.mimeType,
      orElse: () {
        final supportedTypes = SupportedContentTypes.values
            .map((e) => '"${e.value}"')
            .join(', ');
        throw BadRequestException(
          400,
          'Unsupported encoding "$type". '
          'Supported types: $supportedTypes',
        );
      },
    );

    return (
      mimeType: type,
      data: switch (supportedType) {
        SupportedContentTypes.json => await decodeJson(),
        SupportedContentTypes.protobuf => await readBytes(),
      },
    );
  }
}

const jsonContentType = 'application/json';

enum SupportedContentTypes {
  json(jsonContentType),
  protobuf('application/protobuf');

  const SupportedContentTypes(this.value);

  final String value;
}

const contentTypeHeader = 'Content-Type';
