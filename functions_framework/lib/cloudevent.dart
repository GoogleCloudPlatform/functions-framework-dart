import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'src/cloudevent/serializers.dart';

part 'cloudevent.g.dart';

abstract class CloudEvent implements Built<CloudEvent, CloudEventBuilder> {
  String get id;
  Uri get source;
  String get specversion;
  String get type;
  @nullable
  String get datacontenttype;
  @nullable
  Uri get dataschema;
  @nullable
  String get subject;
  @nullable
  DateTime get time;
  @nullable
  String get data;

  CloudEvent._();

  factory CloudEvent([void Function(CloudEventBuilder) updates]) = _$CloudEvent;

  static Serializer<CloudEvent> get serializer => _$cloudEventSerializer;

  dynamic toJson() => serializers.serializeWith(serializer, this);
}

class EventType extends EnumClass {
  static const EventType cloudEventBinary = _$cloudEventBinary;
  static const EventType cloudEventStructured = _$cloudEventStructured;
  static const EventType legacy = _$legacy;

  const EventType._(String name) : super(name);

  static BuiltSet<EventType> get values => _$eventTypeValues;
  static EventType valueOf(String name) => _$eventTypeValueOf(name);
}
