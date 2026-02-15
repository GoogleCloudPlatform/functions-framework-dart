import 'dart:io';

import 'package:google_cloud/google_cloud.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Future<void> main() async {
  final router =
      Router()
        ..get('/project_id', (Request request) async {
          final projectId = await computeProjectId();
          return Response.ok(projectId);
        })
        ..get('/service_account', (Request request) async {
          final email = await serviceAccountEmailFromMetadataServer();
          return Response.ok(email);
        })
        ..get('/logging', (Request request) async {
          currentLogger.info('Hello from google_cloud_e2e');
          return Response.ok('Logged');
        })
        ..get('/metadata', (Request request) async {
          try {
            final client = HttpClient();
            final request = await client.getUrl(gceMetadataUrl(''));
            final response = await request.close();
            await response.drain<void>();
            return Response.ok('Metadata OK');
          } catch (e) {
            return Response.internalServerError(body: 'Metadata failed: $e');
          }
        })
        ..get('/bad_request', (Request request) async {
          throw BadRequestException(400, 'Bad Request Intentional');
        })
        ..get('/server_error', (Request request) async {
          throw ArgumentError('Server Error Intentional');
        });

  final handler = const Pipeline()
      .addMiddleware(
        createLoggingMiddleware(projectId: await computeProjectId()),
      )
      .addHandler(router.call);

  await serveHandler(handler);
}
