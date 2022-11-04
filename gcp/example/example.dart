// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:gcp/gcp.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:shelf/shelf.dart';

Future<void> main() async {
  final server = await _Server.create();

  try {
    await serveHandler(server.handler);
  } finally {
    server.close();
  }
}

class _Server {
  _Server._({
    required this.projectId,
    required this.client,
  });

  static Future<_Server> create() async {
    final projectId = await currentProjectId();
    print('Current GCP project id: $projectId');

    final authClient = await clientViaApplicationDefaultCredentials(
      scopes: [FirestoreApi.datastoreScope],
    );

    return _Server._(projectId: projectId, client: authClient);
  }

  final String projectId;
  final AutoRefreshingAuthClient client;

  late final FirestoreApi api = FirestoreApi(client);
  late final handler = _onlyGetRootMiddleware.addHandler(_incrementHandler);

  Future<Response> _incrementHandler(Request request) async {
    final result = await api.projects.databases.documents.commit(
      _incrementRequest(projectId),
      'projects/$projectId/databases/(default)',
    );

    return Response.ok(
      JsonUtf8Encoder(' ').convert(result),
      headers: {
        'content-type': 'application/json',
      },
    );
  }

  void close() {
    client.close();
  }
}

Handler _onlyGetRootMiddleware(Handler handler) => (Request request) async {
      if (request.method == 'GET' && request.url.pathSegments.isEmpty) {
        return await handler(request);
      }

      return Response.badRequest();
    };

CommitRequest _incrementRequest(String projectId) => CommitRequest(
      writes: [
        Write(
          transform: DocumentTransform(
            document:
                'projects/$projectId/databases/(default)/documents/settings/count',
            fieldTransforms: [
              FieldTransform(
                fieldPath: 'count',
                increment: Value(integerValue: '1'),
              )
            ],
          ),
        ),
      ],
    );
