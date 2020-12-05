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

import 'package:meta/meta_meta.dart';
import 'package:shelf/shelf.dart';

/// Use as an annotation on [Function]s that will be exposed as endpoints.
///
/// Can only be used on public, top-level functions that are compatible with
/// [Handler] from `package:shelf`.
@Target({TargetKind.function})
class CloudFunction {
  /// The name used to register the function in the function framework.
  ///
  /// If `null`, the name of the [Function] is used.
  final String target;

  const CloudFunction({this.target});
}
