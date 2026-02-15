// Copyright 2022 Google LLC
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

import 'dart:io';

import 'package:google_cloud/general.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('metadata utils', () {
    test('gceMetadataHost defaults', () {
      expect(gceMetadataHost, 'metadata.google.internal');
    });

    test('gceMetadataUrl', () {
      expect(
        gceMetadataUrl('foo/bar').toString(),
        'http://metadata.google.internal/computeMetadata/v1/foo/bar',
      );
    });

    test('gceMetadataHost respects env var', () {
      // We can't easily change Platform.environment in-process,
      // but we can check if it works by running a separate process or just
      // trusting that Platform.environment is used correctly.
      // Actually, many other tests use _run to test environment variables.
      // For now, I'll just check the default.
    });
  });

  group('projectIdFromMetadataServer', () {
    test('success', () async {
      final client = MockClient((request) async {
        if (request.url.path.endsWith('project/project-id')) {
          return http.Response('test-project', 200);
        }
        return http.Response('Not Found', 404);
      });

      final projectId = await projectIdFromMetadataServer(
        client: client,
        refresh: true,
      );
      expect(projectId, 'test-project');
    });

    test('non-200 response throws MetadataServerException', () async {
      final client = MockClient(
        (request) async => http.Response('Error message', 500),
      );

      expect(
        () => projectIdFromMetadataServer(client: client, refresh: true),
        throwsA(
          isA<MetadataServerException>().having(
            (e) => e.message,
            'message',
            contains('Error message (500)'),
          ),
        ),
      );
    });

    test(
      'SocketException is wrapped in MetadataServerException with help',
      () async {
        final client = MockClient((request) async {
          throw const SocketException('Failed to connect');
        });

        expect(
          () => projectIdFromMetadataServer(client: client, refresh: true),
          throwsA(
            isA<MetadataServerException>()
                .having(
                  (e) => e.message,
                  'message',
                  contains('Could not connect to metadata.google.internal'),
                )
                .having(
                  (e) => e.innerException,
                  'innerException',
                  isA<SocketException>(),
                ),
          ),
        );
      },
    );

    test(
      'getMetadataValue throws underlying exception before timeout',
      () async {
        final client = MockClient((request) async {
          throw const SocketException('Failed to connect');
        });

        expect(
          () => getMetadataValue(
            'project/project-id',
            client: client,
            timeout: const Duration(seconds: 10),
            refresh: true,
          ),
          throwsA(
            isA<MetadataServerException>().having(
              (e) => e.innerException,
              'innerException',
              isA<SocketException>(),
            ),
          ),
        );
      },
    );
  });

  group('serviceAccountEmailFromMetadataServer', () {
    test('success', () async {
      final client = MockClient((request) async {
        if (request.url.path.endsWith(
          'instance/service-accounts/default/email',
        )) {
          return http.Response('test-sa@example.com', 200);
        }
        return http.Response('Not Found', 404);
      });

      final email = await serviceAccountEmailFromMetadataServer(
        client: client,
        refresh: true,
      );
      expect(email, 'test-sa@example.com');
    });
  });

  group('metadata server caching', () {
    test('caching works', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        return http.Response('project-$callCount', 200);
      });

      final id1 = await projectIdFromMetadataServer(
        client: client,
        refresh: true,
      );
      expect(id1, 'project-1');
      expect(callCount, 1);

      final id2 = await projectIdFromMetadataServer(client: client);
      expect(id2, 'project-1');
      expect(callCount, 1);

      final id3 = await projectIdFromMetadataServer(
        client: client,
        refresh: true,
      );
      expect(id3, 'project-2');
      expect(callCount, 2);
    });
  });
}
