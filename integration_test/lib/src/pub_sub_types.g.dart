// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pub_sub_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubSub _$PubSubFromJson(Map<String, dynamic> json) => PubSub(
      PubSubMessage.fromJson(json['message'] as Map<String, dynamic>),
      json['subscription'] as String,
    );

Map<String, dynamic> _$PubSubToJson(PubSub instance) => <String, dynamic>{
      'message': instance.message,
      'subscription': instance.subscription,
    };

PubSubMessage _$PubSubMessageFromJson(Map<String, dynamic> json) =>
    PubSubMessage(
      json['data'] as String,
      json['messageId'] as String,
      DateTime.parse(json['publishTime'] as String),
      Map<String, String>.from(json['attributes'] as Map),
    );

Map<String, dynamic> _$PubSubMessageToJson(PubSubMessage instance) =>
    <String, dynamic>{
      'data': instance.data,
      'attributes': instance.attributes,
      'messageId': instance.messageId,
      'publishTime': instance.publishTime.toIso8601String(),
    };
