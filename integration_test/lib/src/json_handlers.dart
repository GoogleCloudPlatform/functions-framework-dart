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

import 'dart:async';

import 'package:functions_framework/functions_framework.dart';

import 'pub_sub_types.dart';

@CloudFunction()
void pubSubHandler(PubSub pubSub, RequestContext context) {
  print('subscription: ${pubSub.subscription}');
  context.logger.info('subscription: ${pubSub.subscription}');
  context.responseHeaders['subscription'] = pubSub.subscription;
  context.responseHeaders['multi'] = ['item1', 'item2'];
}

@CloudFunction()
FutureOr<bool> jsonHandler(
  Map<String, dynamic> request,
  RequestContext context,
) {
  print('Keys: ${request.keys.join(', ')}');
  context.responseHeaders['key_count'] = request.keys.length.toString();
  context.responseHeaders['multi'] = ['item1', 'item2'];
  return request.isEmpty;
}
