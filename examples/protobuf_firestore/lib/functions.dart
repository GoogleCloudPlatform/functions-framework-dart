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
import 'dart:io';

import 'package:functions_framework/functions_framework.dart';

import 'src/function_types.dart';

@CloudFunction()
void function(CloudEvent event, RequestContext context) {
  context.logger.info('event subject: ${event.subject}');
  context.logger.debug(jsonEncode(context.request.headers));
  context.responseHeaders['x-data-runtime-types'] = event.data.runtimeType
      .toString();

  final instance = DocumentEventData.fromBuffer(event.data as List<int>);
  stderr.writeln(jsonEncode(instance.toProto3Json()));
}
