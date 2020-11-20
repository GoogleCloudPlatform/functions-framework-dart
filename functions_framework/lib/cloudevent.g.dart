// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloudevent.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EventType _$cloudEventBinary = const EventType._('cloudEventBinary');
const EventType _$cloudEventStructured =
    const EventType._('cloudEventStructured');
const EventType _$legacy = const EventType._('legacy');

EventType _$eventTypeValueOf(String name) {
  switch (name) {
    case 'cloudEventBinary':
      return _$cloudEventBinary;
    case 'cloudEventStructured':
      return _$cloudEventStructured;
    case 'legacy':
      return _$legacy;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<EventType> _$eventTypeValues =
    new BuiltSet<EventType>(const <EventType>[
  _$cloudEventBinary,
  _$cloudEventStructured,
  _$legacy,
]);

Serializer<CloudEvent> _$cloudEventSerializer = new _$CloudEventSerializer();

class _$CloudEventSerializer implements StructuredSerializer<CloudEvent> {
  @override
  final Iterable<Type> types = const [CloudEvent, _$CloudEvent];
  @override
  final String wireName = 'CloudEvent';

  @override
  Iterable<Object> serialize(Serializers serializers, CloudEvent object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'source',
      serializers.serialize(object.source, specifiedType: const FullType(Uri)),
      'specversion',
      serializers.serialize(object.specversion,
          specifiedType: const FullType(String)),
      'type',
      serializers.serialize(object.type, specifiedType: const FullType(String)),
    ];
    if (object.datacontenttype != null) {
      result
        ..add('datacontenttype')
        ..add(serializers.serialize(object.datacontenttype,
            specifiedType: const FullType(String)));
    }
    if (object.dataschema != null) {
      result
        ..add('dataschema')
        ..add(serializers.serialize(object.dataschema,
            specifiedType: const FullType(Uri)));
    }
    if (object.subject != null) {
      result
        ..add('subject')
        ..add(serializers.serialize(object.subject,
            specifiedType: const FullType(String)));
    }
    if (object.time != null) {
      result
        ..add('time')
        ..add(serializers.serialize(object.time,
            specifiedType: const FullType(DateTime)));
    }
    if (object.data != null) {
      result
        ..add('data')
        ..add(serializers.serialize(object.data,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  CloudEvent deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new CloudEventBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'source':
          result.source = serializers.deserialize(value,
              specifiedType: const FullType(Uri)) as Uri;
          break;
        case 'specversion':
          result.specversion = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'type':
          result.type = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'datacontenttype':
          result.datacontenttype = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'dataschema':
          result.dataschema = serializers.deserialize(value,
              specifiedType: const FullType(Uri)) as Uri;
          break;
        case 'subject':
          result.subject = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'time':
          result.time = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
        case 'data':
          result.data = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$CloudEvent extends CloudEvent {
  @override
  final String id;
  @override
  final Uri source;
  @override
  final String specversion;
  @override
  final String type;
  @override
  final String datacontenttype;
  @override
  final Uri dataschema;
  @override
  final String subject;
  @override
  final DateTime time;
  @override
  final String data;

  factory _$CloudEvent([void Function(CloudEventBuilder) updates]) =>
      (new CloudEventBuilder()..update(updates)).build();

  _$CloudEvent._(
      {this.id,
      this.source,
      this.specversion,
      this.type,
      this.datacontenttype,
      this.dataschema,
      this.subject,
      this.time,
      this.data})
      : super._() {
    if (id == null) {
      throw new BuiltValueNullFieldError('CloudEvent', 'id');
    }
    if (source == null) {
      throw new BuiltValueNullFieldError('CloudEvent', 'source');
    }
    if (specversion == null) {
      throw new BuiltValueNullFieldError('CloudEvent', 'specversion');
    }
    if (type == null) {
      throw new BuiltValueNullFieldError('CloudEvent', 'type');
    }
  }

  @override
  CloudEvent rebuild(void Function(CloudEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CloudEventBuilder toBuilder() => new CloudEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CloudEvent &&
        id == other.id &&
        source == other.source &&
        specversion == other.specversion &&
        type == other.type &&
        datacontenttype == other.datacontenttype &&
        dataschema == other.dataschema &&
        subject == other.subject &&
        time == other.time &&
        data == other.data;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc($jc($jc(0, id.hashCode), source.hashCode),
                                specversion.hashCode),
                            type.hashCode),
                        datacontenttype.hashCode),
                    dataschema.hashCode),
                subject.hashCode),
            time.hashCode),
        data.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('CloudEvent')
          ..add('id', id)
          ..add('source', source)
          ..add('specversion', specversion)
          ..add('type', type)
          ..add('datacontenttype', datacontenttype)
          ..add('dataschema', dataschema)
          ..add('subject', subject)
          ..add('time', time)
          ..add('data', data))
        .toString();
  }
}

class CloudEventBuilder implements Builder<CloudEvent, CloudEventBuilder> {
  _$CloudEvent _$v;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  Uri _source;
  Uri get source => _$this._source;
  set source(Uri source) => _$this._source = source;

  String _specversion;
  String get specversion => _$this._specversion;
  set specversion(String specversion) => _$this._specversion = specversion;

  String _type;
  String get type => _$this._type;
  set type(String type) => _$this._type = type;

  String _datacontenttype;
  String get datacontenttype => _$this._datacontenttype;
  set datacontenttype(String datacontenttype) =>
      _$this._datacontenttype = datacontenttype;

  Uri _dataschema;
  Uri get dataschema => _$this._dataschema;
  set dataschema(Uri dataschema) => _$this._dataschema = dataschema;

  String _subject;
  String get subject => _$this._subject;
  set subject(String subject) => _$this._subject = subject;

  DateTime _time;
  DateTime get time => _$this._time;
  set time(DateTime time) => _$this._time = time;

  String _data;
  String get data => _$this._data;
  set data(String data) => _$this._data = data;

  CloudEventBuilder();

  CloudEventBuilder get _$this {
    if (_$v != null) {
      _id = _$v.id;
      _source = _$v.source;
      _specversion = _$v.specversion;
      _type = _$v.type;
      _datacontenttype = _$v.datacontenttype;
      _dataschema = _$v.dataschema;
      _subject = _$v.subject;
      _time = _$v.time;
      _data = _$v.data;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CloudEvent other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$CloudEvent;
  }

  @override
  void update(void Function(CloudEventBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$CloudEvent build() {
    final _$result = _$v ??
        new _$CloudEvent._(
            id: id,
            source: source,
            specversion: specversion,
            type: type,
            datacontenttype: datacontenttype,
            dataschema: dataschema,
            subject: subject,
            time: time,
            data: data);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
