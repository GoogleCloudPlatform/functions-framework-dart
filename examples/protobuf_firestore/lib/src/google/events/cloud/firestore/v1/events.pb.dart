//
//  Generated code. Do not modify.
//  source: google/events/cloud/firestore/v1/events.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'data.pb.dart' as $3;

class DocumentCreatedEvent extends $pb.GeneratedMessage {
  factory DocumentCreatedEvent() => create();
  DocumentCreatedEvent._() : super();
  factory DocumentCreatedEvent.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DocumentCreatedEvent.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentCreatedEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.events.cloud.firestore.v1'),
      createEmptyInstance: create)
    ..aOM<$3.DocumentEventData>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $3.DocumentEventData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DocumentCreatedEvent clone() =>
      DocumentCreatedEvent()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DocumentCreatedEvent copyWith(void Function(DocumentCreatedEvent) updates) =>
      super.copyWith((message) => updates(message as DocumentCreatedEvent))
          as DocumentCreatedEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentCreatedEvent create() => DocumentCreatedEvent._();
  DocumentCreatedEvent createEmptyInstance() => create();
  static $pb.PbList<DocumentCreatedEvent> createRepeated() =>
      $pb.PbList<DocumentCreatedEvent>();
  @$core.pragma('dart2js:noInline')
  static DocumentCreatedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocumentCreatedEvent>(create);
  static DocumentCreatedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $3.DocumentEventData get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($3.DocumentEventData v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  $3.DocumentEventData ensureData() => $_ensure(0);
}

class DocumentUpdatedEvent extends $pb.GeneratedMessage {
  factory DocumentUpdatedEvent() => create();
  DocumentUpdatedEvent._() : super();
  factory DocumentUpdatedEvent.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DocumentUpdatedEvent.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentUpdatedEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.events.cloud.firestore.v1'),
      createEmptyInstance: create)
    ..aOM<$3.DocumentEventData>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $3.DocumentEventData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DocumentUpdatedEvent clone() =>
      DocumentUpdatedEvent()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DocumentUpdatedEvent copyWith(void Function(DocumentUpdatedEvent) updates) =>
      super.copyWith((message) => updates(message as DocumentUpdatedEvent))
          as DocumentUpdatedEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentUpdatedEvent create() => DocumentUpdatedEvent._();
  DocumentUpdatedEvent createEmptyInstance() => create();
  static $pb.PbList<DocumentUpdatedEvent> createRepeated() =>
      $pb.PbList<DocumentUpdatedEvent>();
  @$core.pragma('dart2js:noInline')
  static DocumentUpdatedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocumentUpdatedEvent>(create);
  static DocumentUpdatedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $3.DocumentEventData get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($3.DocumentEventData v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  $3.DocumentEventData ensureData() => $_ensure(0);
}

class DocumentDeletedEvent extends $pb.GeneratedMessage {
  factory DocumentDeletedEvent() => create();
  DocumentDeletedEvent._() : super();
  factory DocumentDeletedEvent.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DocumentDeletedEvent.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentDeletedEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.events.cloud.firestore.v1'),
      createEmptyInstance: create)
    ..aOM<$3.DocumentEventData>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $3.DocumentEventData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DocumentDeletedEvent clone() =>
      DocumentDeletedEvent()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DocumentDeletedEvent copyWith(void Function(DocumentDeletedEvent) updates) =>
      super.copyWith((message) => updates(message as DocumentDeletedEvent))
          as DocumentDeletedEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentDeletedEvent create() => DocumentDeletedEvent._();
  DocumentDeletedEvent createEmptyInstance() => create();
  static $pb.PbList<DocumentDeletedEvent> createRepeated() =>
      $pb.PbList<DocumentDeletedEvent>();
  @$core.pragma('dart2js:noInline')
  static DocumentDeletedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocumentDeletedEvent>(create);
  static DocumentDeletedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $3.DocumentEventData get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($3.DocumentEventData v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  $3.DocumentEventData ensureData() => $_ensure(0);
}

class DocumentWrittenEvent extends $pb.GeneratedMessage {
  factory DocumentWrittenEvent() => create();
  DocumentWrittenEvent._() : super();
  factory DocumentWrittenEvent.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DocumentWrittenEvent.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentWrittenEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.events.cloud.firestore.v1'),
      createEmptyInstance: create)
    ..aOM<$3.DocumentEventData>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $3.DocumentEventData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DocumentWrittenEvent clone() =>
      DocumentWrittenEvent()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DocumentWrittenEvent copyWith(void Function(DocumentWrittenEvent) updates) =>
      super.copyWith((message) => updates(message as DocumentWrittenEvent))
          as DocumentWrittenEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentWrittenEvent create() => DocumentWrittenEvent._();
  DocumentWrittenEvent createEmptyInstance() => create();
  static $pb.PbList<DocumentWrittenEvent> createRepeated() =>
      $pb.PbList<DocumentWrittenEvent>();
  @$core.pragma('dart2js:noInline')
  static DocumentWrittenEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocumentWrittenEvent>(create);
  static DocumentWrittenEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $3.DocumentEventData get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($3.DocumentEventData v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  $3.DocumentEventData ensureData() => $_ensure(0);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
