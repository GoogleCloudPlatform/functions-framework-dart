// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: require_trailing_commas

part of 'cloud_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloudEvent _$CloudEventFromJson(Map<String, dynamic> json) => $checkedCreate(
      'CloudEvent',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['id', 'source', 'specversion', 'type'],
        );
        final val = CloudEvent(
          id: $checkedConvert('id', (v) => v as String),
          source: $checkedConvert('source', (v) => Uri.parse(v as String)),
          specVersion: $checkedConvert('specversion', (v) => v as String),
          type: $checkedConvert('type', (v) => v as String),
          data: $checkedConvert('data', (v) => v),
          dataContentType:
              $checkedConvert('datacontenttype', (v) => v as String?),
          dataSchema: $checkedConvert(
              'dataschema', (v) => v == null ? null : Uri.parse(v as String)),
          subject: $checkedConvert('subject', (v) => v as String?),
          time: $checkedConvert(
              'time', (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {
        'specVersion': 'specversion',
        'dataContentType': 'datacontenttype',
        'dataSchema': 'dataschema'
      },
    );

Map<String, dynamic> _$CloudEventToJson(CloudEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source': instance.source.toString(),
      'specversion': instance.specVersion,
      'type': instance.type,
      if (instance.dataContentType case final value?) 'datacontenttype': value,
      if (instance.data case final value?) 'data': value,
      if (instance.dataSchema?.toString() case final value?)
        'dataschema': value,
      if (instance.subject case final value?) 'subject': value,
      if (instance.time?.toIso8601String() case final value?) 'time': value,
    };
