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

import 'package:http/http.dart' as http;

Future<http.Response> _getPubInfo(String appName) async {
  final pubInfo = Uri.https('pub.dev', '/packages/$appName.json');
  return await http.get(pubInfo);
}

List<String> _getPubVersions(http.Response resp) =>
    ((jsonDecode(resp.body) as Map)['versions'] as List).cast<String>();

/// Check pub.dev for newer versions.
Future<String?> checkPubForLaterVersion(String appName, String version) async =>
    Future<String?>(() async {
      final resp = await _getPubInfo(appName);
      final versions = _getPubVersions(resp);
      return (version != versions.last) ? versions.last : null;
    }).catchError((e) => null);
