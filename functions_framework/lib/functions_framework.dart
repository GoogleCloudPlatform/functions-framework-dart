// Copyright (c) 2020, the Dart project authors.
// Please see the AUTHORS file or details. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta_meta.dart';

@Target({TargetKind.function})
class CloudFunction {
  final String target;

  const CloudFunction([this.target = 'function']);
}
