// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';

import 'constants.dart';

class CloudMetadata {
  static const _host = 'http://metadata.google.internal/computeMetadata/v1/';
  static const _requestHeaders = {'Metadata-Flavor': 'Google'};

  final _client = IOClient();

  final String cloudTraceContext;

  CloudMetadata({this.cloudTraceContext});

  Future<ProjectInfo> projectInfo() async {
    final response = await _get('project/?recursive=true');

    return ProjectInfo(
      response['numericProjectId'] as int,
      response['projectId'] as String,
    );
  }

  Future<Map<String, dynamic>> recursive() => _get('?recursive=true');

  Future<Map<String, dynamic>> token() =>
      _get('instance/service-accounts/default/token');

  Future<Map<String, dynamic>> _get(String path) async {
    final url = Uri.parse('$_host/$path');
    final response = await _client.get(
      url,
      headers: {
        ..._requestHeaders,
        if (cloudTraceContext != null)
          cloudTraceContextHeader: cloudTraceContext,
      },
    );

    if (response.statusCode != 200) {
      throw HttpException(
        '${response.body} (${response.statusCode})',
        uri: url,
      );
    }

    final json = jsonDecode(response.body);

    return json as Map<String, dynamic>;
  }

  void close() {
    _client.close();
  }

  /// Returns the project ID if executed on a Google Cloud instance with a
  /// metadata service available.
  ///
  /// Otherwise, `null`.
  static Future<String> projectId() async {
    if (_isHosted) {
      // Only attempt to get instance metadata if it seems we're running in a
      // hosted environment.
      final metadataClient = CloudMetadata();
      try {
        final projectInfo = await metadataClient.projectInfo();
        return projectInfo.projectId;
      } catch (_) {
        stderr.writeln('Could not retreive cloud instance metadata.');
      } finally {
        metadataClient.close();
      }
    }
    return null;
  }
}

/// `true` if the "K_SERVICE" environment variable is set –
/// likely running on Cloud Run.
///
/// See https://cloud.google.com/run/docs/reference/container-contract#env-vars
bool get _isHosted => Platform.environment.containsKey('K_SERVICE');

class ProjectInfo {
  final int numericProjectId;
  final String projectId;

  ProjectInfo(this.numericProjectId, this.projectId);

  @override
  String toString() => 'ProjectInfo: $projectId ($numericProjectId)';
}
