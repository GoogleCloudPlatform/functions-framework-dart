// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: prefer_expression_function_bodies

part of 'cloud_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloudEvent _$CloudEventFromJson(Map<String, dynamic> json) {
  return $checkedNew('CloudEvent', json, () {
    $checkKeys(json,
        requiredKeys: const ['id', 'source', 'specversion', 'type']);
    final val = CloudEvent(
      id: $checkedConvert(json, 'id', (v) => v as String),
      source: $checkedConvert(json, 'source', (v) => Uri.parse(v as String)),
      specVersion: $checkedConvert(json, 'specversion', (v) => v as String),
      type: $checkedConvert(json, 'type', (v) => v as String),
      data: $checkedConvert(json, 'data', (v) => v),
      dataContentType:
          $checkedConvert(json, 'datacontenttype', (v) => v as String?),
      dataSchema: $checkedConvert(
          json, 'dataschema', (v) => v == null ? null : Uri.parse(v as String)),
      subject: $checkedConvert(json, 'subject', (v) => v as String?),
      time: $checkedConvert(
          json, 'time', (v) => v == null ? null : DateTime.parse(v as String)),
    );
    return val;
  }, fieldKeyMap: const {
    'specVersion': 'specversion',
    'dataContentType': 'datacontenttype',
    'dataSchema': 'dataschema'
  });
}

Map<String, dynamic> _$CloudEventToJson(CloudEvent instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'source': instance.source.toString(),
    'specversion': instance.specVersion,
    'type': instance.type,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('datacontenttype', instance.dataContentType);
  writeNotNull('data', instance.data);
  writeNotNull('dataschema', instance.dataSchema?.toString());
  writeNotNull('subject', instance.subject);
  writeNotNull('time', instance.time?.toIso8601String());
  return val;
}
