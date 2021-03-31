// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GreetingRequest _$GreetingRequestFromJson(Map<String, dynamic> json) {
  return GreetingRequest(
    name: json['name'] as String?,
  );
}

Map<String, dynamic> _$GreetingRequestToJson(GreetingRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

GreetingResponse _$GreetingResponseFromJson(Map<String, dynamic> json) {
  return GreetingResponse(
    salutation: json['salutation'] as String,
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$GreetingResponseToJson(GreetingResponse instance) =>
    <String, dynamic>{
      'salutation': instance.salutation,
      'name': instance.name,
    };
