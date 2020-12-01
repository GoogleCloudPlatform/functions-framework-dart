import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

const cloudTraceContextHeader = 'x-cloud-trace-context';

class CloudMetadata {
  static const _host = 'http://metadata.google.internal';
  static const _requestHeaders = {'Metadata-Flavor': 'Google'};

  final _client = IOClient();

  final String cloudTraceContext;

  CloudMetadata({this.cloudTraceContext});

  Future<Map<String, dynamic>> recursive() =>
      _get('/computeMetadata/v1/?recursive=true');

  Future<Map<String, dynamic>> token() =>
      _get('/computeMetadata/v1/instance/service-accounts/default/token');

  Future<Map<String, dynamic>> _get(String path) async {
    http.Response response;
    try {
      response = await _client.get(
        '$_host/$path',
        headers: {
          ..._requestHeaders,
          if (cloudTraceContext != null)
            cloudTraceContextHeader: cloudTraceContext,
        },
      );
    } on SocketException catch (e) {
      return {
        'ERROR': e.message,
        if (e.port != null) 'port': e.port,
        if (e.address != null) 'address': e.address,
        'OS_ERROR': e.osError.toString()
      };
    }

    if (response.statusCode != 200) {
      return {
        'ERROR': response.body,
        'status_code': response.statusCode,
        'headers': response.headers,
      };
    }

    final json = jsonDecode(response.body);

    return json as Map<String, dynamic>;
  }

  void close() {
    _client.close();
  }
}
