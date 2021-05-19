import 'package:functions_framework/functions_framework.dart';

class JsonType {
  Map<String, dynamic> toJson() => throw UnimplementedError();
}

class MixedInType with JsonType {
  // ignore: avoid_unused_constructor_parameters
  factory MixedInType.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
}

@CloudFunction()
MixedInType syncFunction(MixedInType request) => throw UnimplementedError();
