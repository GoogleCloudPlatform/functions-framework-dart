import 'package:json_annotation/json_annotation.dart';

part 'api_types.g.dart';

@JsonSerializable()
class GreetingRequest {
  final String? name;

  GreetingRequest({this.name});

  factory GreetingRequest.fromJson(Map<String, dynamic> json) =>
      _$GreetingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GreetingRequestToJson(this);
}

@JsonSerializable()
class GreetingResponse {
  final String salutation;
  final String name;

  GreetingResponse({required this.salutation, required this.name});

  factory GreetingResponse.fromJson(Map<String, dynamic> json) =>
      _$GreetingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GreetingResponseToJson(this);
}
