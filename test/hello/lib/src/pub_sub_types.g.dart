// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: prefer_expression_function_bodies

part of 'pub_sub_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubSub _$PubSubFromJson(Map<String, dynamic> json) {
  return PubSub(
    json['message'] == null
        ? null
        : PubSubMessage.fromJson(json['message'] as Map<String, dynamic>),
    json['subscription'] as String,
  );
}

Map<String, dynamic> _$PubSubToJson(PubSub instance) => <String, dynamic>{
      'message': instance.message,
      'subscription': instance.subscription,
    };

PubSubMessage _$PubSubMessageFromJson(Map<String, dynamic> json) {
  return PubSubMessage(
    json['data'] as String,
    json['messageId'] as String,
    json['publishTime'] == null
        ? null
        : DateTime.parse(json['publishTime'] as String),
    (json['attributes'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
  );
}

Map<String, dynamic> _$PubSubMessageToJson(PubSubMessage instance) =>
    <String, dynamic>{
      'data': instance.data,
      'attributes': instance.attributes,
      'messageId': instance.messageId,
      'publishTime': instance.publishTime?.toIso8601String(),
    };
