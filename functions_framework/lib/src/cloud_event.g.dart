// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: prefer_expression_function_bodies

part of 'cloud_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloudEvent<T> _$CloudEventFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object json) fromJsonT,
) {
  return $checkedNew('CloudEvent', json, () {
    $checkKeys(json,
        requiredKeys: const ['id', 'source', 'specversion', 'type']);
    final val = CloudEvent<T>(
      id: $checkedConvert(json, 'id', (v) => v as String),
      source: $checkedConvert(
          json, 'source', (v) => v == null ? null : Uri.parse(v as String)),
      specVersion: $checkedConvert(json, 'specversion', (v) => v as String),
      type: $checkedConvert(json, 'type', (v) => v as String),
      data: $checkedConvert(json, 'data', (v) => fromJsonT(v)),
      dataContentType:
          $checkedConvert(json, 'datacontenttype', (v) => v as String),
      dataSchema: $checkedConvert(
          json, 'dataschema', (v) => v == null ? null : Uri.parse(v as String)),
      subject: $checkedConvert(json, 'subject', (v) => v as String),
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

Map<String, dynamic> _$CloudEventToJson<T>(
  CloudEvent<T> instance,
  Object Function(T value) toJsonT,
) {
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
  writeNotNull('data', toJsonT(instance.data));
  writeNotNull('dataschema', instance.dataSchema?.toString());
  writeNotNull('subject', instance.subject);
  writeNotNull('time', instance.time?.toIso8601String());
  return val;
}
