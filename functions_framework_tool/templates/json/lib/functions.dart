import 'package:functions_framework/functions_framework.dart';
import 'package:json_annotation/json_annotation.dart';

part 'functions.g.dart';

@JsonSerializable(nullable: false)
class GreetingResponse {
  final String salutation;
  final String name;

  GreetingResponse({this.salutation, this.name});

  factory GreetingResponse.fromJson(Map<String, dynamic> json) =>
      _$GreetingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GreetingResponseToJson(this);

  @override
  bool operator ==(Object other) =>
      other is GreetingResponse &&
      other.salutation == salutation &&
      other.name == name;

  @override
  int get hashCode => salutation.hashCode ^ name.hashCode;
}

@CloudFunction()
GreetingResponse function(Map<String, dynamic> request) {
  final name = request['name'] as String ?? 'World';
  final json = GreetingResponse(salutation: 'Hello', name: name);
  return json;
}
