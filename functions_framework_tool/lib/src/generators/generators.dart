import 'package:stagehand/stagehand.dart';

import 'package_simple.dart';

/// A list of Dart Functions Framework project generators
final List<Generator> generators = [
  PackageSimpleGenerator(),
]..sort();
