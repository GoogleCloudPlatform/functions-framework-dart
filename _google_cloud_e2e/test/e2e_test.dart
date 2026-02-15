import 'dart:io';

import 'package:google_cloud/constants.dart' as cloud_constants;
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  final url = Platform.environment['E2E_URL'];

  group('E2E Validation', () {
    if (url == null) {
      test('E2E_URL not set', () {
        print('Skipping E2E tests because E2E_URL is not set.');
      });
      return;
    }

    final rootUri = Uri.parse(url);

    test('get project_id', () async {
      final response = await http.get(rootUri.replace(path: '/project_id'));
      expect(response.statusCode, 200);
      expect(response.body, isNotEmpty);
      print('Project ID: ${response.body}');
    });

    test('get service_account', () async {
      final response = await http.get(
        rootUri.replace(path: '/service_account'),
      );
      expect(response.statusCode, 200);
      expect(response.body, contains('@'));
      print('Service Account: ${response.body}');
    });

    test('logging', () async {
      const startBit = 'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6';
      final response = await http.get(
        rootUri.replace(path: '/logging'),
        headers: {
          cloud_constants.cloudTraceContextHeader: '$startBit/12345;o=1',
        },
      );
      expect(response.statusCode, 200);
      expect(response.body, 'Logged');
      expect(
        response.headers,
        containsPair(cloud_constants.cloudTraceContextHeader, '$startBit;o=1'),
      );
    });

    test('metadata checks', () async {
      final response = await http.get(rootUri.replace(path: '/metadata'));
      expect(response.statusCode, 200);
      expect(response.body, 'Metadata OK');
    });

    test('bad request', () async {
      final response = await http.get(rootUri.replace(path: '/bad_request'));
      expect(response.statusCode, 400);
      expect(response.body, contains('Bad Request Intentional'));
    });

    test('server error', () async {
      final response = await http.get(rootUri.replace(path: '/server_error'));
      expect(response.statusCode, 500);
      expect(
        response.headers,
        contains(cloud_constants.cloudTraceContextHeader),
      );
      print('Server Error Headers: ${response.headers}');
      print('Server Error Body: ${response.body}');
    });
  });
}
