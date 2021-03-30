import 'package:json_annotation/json_annotation.dart';

part 'api_types.g.dart';

@JsonSerializable()
class GreetingRequest {
  final String? name;

  GreetingRequest({this.name});

  factory GreetingRequest.fromJson(Map<String, dynamic> json) =>
      _$GreetingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GreetingRequestToJson(this);

  @override
  bool operator ==(Object other) =>
      other is GreetingRequest && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

@JsonSerializable()
class GreetingResponse {
  final String salutation;
  final String name;

  GreetingResponse({required this.salutation, required this.name});

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
