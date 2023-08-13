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

import 'package:google_cloud/google_cloud.dart';
import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';

import 'cloud_event.dart';

/// Provides access to a [RequestLogger], the source [Request] and response
/// headers for a typed function handler.
///
/// Can be used as an optional second parameter in a function definition that
/// accepts a [CloudEvent] or a custom type.
class RequestContext {
  final RequestLogger logger;

  /// Access to the source [Request] object.
  ///
  /// Accessing `read` or `readAsString` will throw an error because the body
  /// of the [Request] has already been read.
  final Request request;

  final responseHeaders = <String, /* String | List<String> */ Object>{};

  RequestContext._(this.request) : logger = currentLogger;
}

@internal
RequestContext contextForRequest(Request request) => RequestContext._(request);
