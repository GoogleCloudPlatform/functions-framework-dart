// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: prefer_expression_function_bodies

part of 'cloud_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloudEvent _$CloudEventFromJson(Map<String, dynamic> json) {
  return CloudEvent(
    id: json['id'] as String,
    source: json['source'] == null ? null : Uri.parse(json['source'] as String),
    specVersion: json['specversion'] as String,
    type: json['type'] as String,
    data: json['data'],
    dataContentType: json['datacontenttype'] as String,
    dataSchema: json['dataschema'] == null
        ? null
        : Uri.parse(json['dataschema'] as String),
    subject: json['subject'] as String,
    time: json['time'] == null ? null : DateTime.parse(json['time'] as String),
  );
}

Map<String, dynamic> _$CloudEventToJson(CloudEvent instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('source', instance.source?.toString());
  writeNotNull('specversion', instance.specVersion);
  writeNotNull('type', instance.type);
  writeNotNull('datacontenttype', instance.dataContentType);
  writeNotNull('data', instance.data);
  writeNotNull('dataschema', instance.dataSchema?.toString());
  writeNotNull('subject', instance.subject);
  writeNotNull('time', instance.time?.toIso8601String());
  return val;
}
