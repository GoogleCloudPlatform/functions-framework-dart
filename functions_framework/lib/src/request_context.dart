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

import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';

import 'log_severity.dart';
import 'logging.dart';

class RequestContext {
  final RequestLogger logger;
  final Request _request;

  RequestContext._(this._request) : logger = loggerForRequest(_request);

  /// The HTTP headers with case-insensitive keys.
  ///
  /// If a header occurs more than once in the query string, they are mapped to
  /// by concatenating them with a comma.
  ///
  /// The returned map is unmodifiable.
  Map<String, String> get headers => _request.headers;

  /// The HTTP headers with multiple values with case-insensitive keys.
  ///
  /// If a header occurs only once, its value is a singleton list.
  /// If a header occurs with no value, the empty string is used as the value
  /// for that occurrence.
  ///
  /// The returned map and the lists it contains are unmodifiable.
  Map<String, List<String>> get headersAll => _request.headersAll;
}

@internal
RequestContext contextForRequest(Request request) => RequestContext._(request);
