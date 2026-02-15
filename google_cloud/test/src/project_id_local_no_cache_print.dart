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

import 'package:google_cloud/constants.dart';
import 'package:google_cloud/google_cloud.dart';

Future<void> main() async {
  // First call - should read from credentials file.
  // Note: Local discovery strategies are NOT cached.
  final projectId1 = await computeProjectId();
  print('First call: $projectId1');

  // Modify the credentials file to a different project ID
  final credPath = Platform.environment[credentialsPathEnvironmentVariable];
  if (credPath != null) {
    final credFile = File(credPath);
    await credFile.writeAsString('{"project_id": "modified-project-id"}');
  }

  // Second call - should return new value because the cache was not accessed or
  // set in the previous request
  final projectId2 = await computeProjectId();
  print('Second call: $projectId2');

  // If caching is removed for local strategies, they should be different
  if (projectId1 != projectId2 && projectId2 == 'modified-project-id') {
    print('NOT_CACHED');
  } else {
    print('CACHE_STILL_WORKS_OR_ERROR');
    exitCode = 1;
  }
}
