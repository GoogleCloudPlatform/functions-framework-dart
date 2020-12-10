// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

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
