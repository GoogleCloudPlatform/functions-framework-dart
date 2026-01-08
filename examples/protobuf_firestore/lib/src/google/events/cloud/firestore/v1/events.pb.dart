// This is a generated file - do not edit.
//
// Generated from google/events/cloud/firestore/v1/events.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'data.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// The CloudEvent raised when a Firestore document is created.
class DocumentCreatedEvent extends $pb.GeneratedMessage {
  factory DocumentCreatedEvent({
    $0.DocumentEventData? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  DocumentCreatedEvent._();

  factory DocumentCreatedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DocumentCreatedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentCreatedEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.events.cloud.firestore.v1'),
      createEmptyInstance: create)
    ..aOM<$0.DocumentEventData>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $0.DocumentEventData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentCreatedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentCreatedEvent copyWith(void Function(DocumentCreatedEvent) updates) =>
      super.copyWith((message) => updates(message as DocumentCreatedEvent))
          as DocumentCreatedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentCreatedEvent create() => DocumentCreatedEvent._();
  @$core.override
  DocumentCreatedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DocumentCreatedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocumentCreatedEvent>(create);
  static DocumentCreatedEvent? _defaultInstance;

  /// The data associated with the event.
  @$pb.TagNumber(1)
  $0.DocumentEventData get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($0.DocumentEventData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.DocumentEventData ensureData() => $_ensure(0);
}

/// The CloudEvent raised when a Firestore document is updated.
class DocumentUpdatedEvent extends $pb.GeneratedMessage {
  factory DocumentUpdatedEvent({
    $0.DocumentEventData? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  DocumentUpdatedEvent._();

  factory DocumentUpdatedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DocumentUpdatedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentUpdatedEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.events.cloud.firestore.v1'),
      createEmptyInstance: create)
    ..aOM<$0.DocumentEventData>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $0.DocumentEventData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentUpdatedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentUpdatedEvent copyWith(void Function(DocumentUpdatedEvent) updates) =>
      super.copyWith((message) => updates(message as DocumentUpdatedEvent))
          as DocumentUpdatedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentUpdatedEvent create() => DocumentUpdatedEvent._();
  @$core.override
  DocumentUpdatedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DocumentUpdatedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocumentUpdatedEvent>(create);
  static DocumentUpdatedEvent? _defaultInstance;

  /// The data associated with the event.
  @$pb.TagNumber(1)
  $0.DocumentEventData get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($0.DocumentEventData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.DocumentEventData ensureData() => $_ensure(0);
}

/// The CloudEvent raised when a Firestore document is deleted.
class DocumentDeletedEvent extends $pb.GeneratedMessage {
  factory DocumentDeletedEvent({
    $0.DocumentEventData? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  DocumentDeletedEvent._();

  factory DocumentDeletedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DocumentDeletedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentDeletedEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.events.cloud.firestore.v1'),
      createEmptyInstance: create)
    ..aOM<$0.DocumentEventData>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $0.DocumentEventData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentDeletedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentDeletedEvent copyWith(void Function(DocumentDeletedEvent) updates) =>
      super.copyWith((message) => updates(message as DocumentDeletedEvent))
          as DocumentDeletedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentDeletedEvent create() => DocumentDeletedEvent._();
  @$core.override
  DocumentDeletedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DocumentDeletedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocumentDeletedEvent>(create);
  static DocumentDeletedEvent? _defaultInstance;

  /// The data associated with the event.
  @$pb.TagNumber(1)
  $0.DocumentEventData get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($0.DocumentEventData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.DocumentEventData ensureData() => $_ensure(0);
}

/// The CloudEvent raised when a Firestore document is created, updated or
/// deleted.
class DocumentWrittenEvent extends $pb.GeneratedMessage {
  factory DocumentWrittenEvent({
    $0.DocumentEventData? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  DocumentWrittenEvent._();

  factory DocumentWrittenEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DocumentWrittenEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentWrittenEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.events.cloud.firestore.v1'),
      createEmptyInstance: create)
    ..aOM<$0.DocumentEventData>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $0.DocumentEventData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentWrittenEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentWrittenEvent copyWith(void Function(DocumentWrittenEvent) updates) =>
      super.copyWith((message) => updates(message as DocumentWrittenEvent))
          as DocumentWrittenEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentWrittenEvent create() => DocumentWrittenEvent._();
  @$core.override
  DocumentWrittenEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DocumentWrittenEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocumentWrittenEvent>(create);
  static DocumentWrittenEvent? _defaultInstance;

  /// The data associated with the event.
  @$pb.TagNumber(1)
  $0.DocumentEventData get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($0.DocumentEventData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.DocumentEventData ensureData() => $_ensure(0);
}

/// The CloudEvent with Auth Context raised when a Firestore document is created.
class DocumentCreatedEventWithAuthContext extends $pb.GeneratedMessage {
  factory DocumentCreatedEventWithAuthContext({
    $0.DocumentEventData? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  DocumentCreatedEventWithAuthContext._();

  factory DocumentCreatedEventWithAuthContext.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DocumentCreatedEventWithAuthContext.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentCreatedEventWithAuthContext',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.events.cloud.firestore.v1'),
      createEmptyInstance: create)
    ..aOM<$0.DocumentEventData>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $0.DocumentEventData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentCreatedEventWithAuthContext clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentCreatedEventWithAuthContext copyWith(
          void Function(DocumentCreatedEventWithAuthContext) updates) =>
      super.copyWith((message) =>
              updates(message as DocumentCreatedEventWithAuthContext))
          as DocumentCreatedEventWithAuthContext;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentCreatedEventWithAuthContext create() =>
      DocumentCreatedEventWithAuthContext._();
  @$core.override
  DocumentCreatedEventWithAuthContext createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DocumentCreatedEventWithAuthContext getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          DocumentCreatedEventWithAuthContext>(create);
  static DocumentCreatedEventWithAuthContext? _defaultInstance;

  /// The data associated with the event.
  @$pb.TagNumber(1)
  $0.DocumentEventData get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($0.DocumentEventData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.DocumentEventData ensureData() => $_ensure(0);
}

/// The CloudEvent with Auth Context raised when a Firestore document is updated.
class DocumentUpdatedEventWithAuthContext extends $pb.GeneratedMessage {
  factory DocumentUpdatedEventWithAuthContext({
    $0.DocumentEventData? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  DocumentUpdatedEventWithAuthContext._();

  factory DocumentUpdatedEventWithAuthContext.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DocumentUpdatedEventWithAuthContext.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentUpdatedEventWithAuthContext',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.events.cloud.firestore.v1'),
      createEmptyInstance: create)
    ..aOM<$0.DocumentEventData>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $0.DocumentEventData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentUpdatedEventWithAuthContext clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentUpdatedEventWithAuthContext copyWith(
          void Function(DocumentUpdatedEventWithAuthContext) updates) =>
      super.copyWith((message) =>
              updates(message as DocumentUpdatedEventWithAuthContext))
          as DocumentUpdatedEventWithAuthContext;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentUpdatedEventWithAuthContext create() =>
      DocumentUpdatedEventWithAuthContext._();
  @$core.override
  DocumentUpdatedEventWithAuthContext createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DocumentUpdatedEventWithAuthContext getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          DocumentUpdatedEventWithAuthContext>(create);
  static DocumentUpdatedEventWithAuthContext? _defaultInstance;

  /// The data associated with the event.
  @$pb.TagNumber(1)
  $0.DocumentEventData get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($0.DocumentEventData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.DocumentEventData ensureData() => $_ensure(0);
}

/// The CloudEvent with Auth Context raised when a Firestore document is deleted.
class DocumentDeletedEventWithAuthContext extends $pb.GeneratedMessage {
  factory DocumentDeletedEventWithAuthContext({
    $0.DocumentEventData? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  DocumentDeletedEventWithAuthContext._();

  factory DocumentDeletedEventWithAuthContext.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DocumentDeletedEventWithAuthContext.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentDeletedEventWithAuthContext',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.events.cloud.firestore.v1'),
      createEmptyInstance: create)
    ..aOM<$0.DocumentEventData>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $0.DocumentEventData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentDeletedEventWithAuthContext clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentDeletedEventWithAuthContext copyWith(
          void Function(DocumentDeletedEventWithAuthContext) updates) =>
      super.copyWith((message) =>
              updates(message as DocumentDeletedEventWithAuthContext))
          as DocumentDeletedEventWithAuthContext;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentDeletedEventWithAuthContext create() =>
      DocumentDeletedEventWithAuthContext._();
  @$core.override
  DocumentDeletedEventWithAuthContext createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DocumentDeletedEventWithAuthContext getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          DocumentDeletedEventWithAuthContext>(create);
  static DocumentDeletedEventWithAuthContext? _defaultInstance;

  /// The data associated with the event.
  @$pb.TagNumber(1)
  $0.DocumentEventData get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($0.DocumentEventData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.DocumentEventData ensureData() => $_ensure(0);
}

/// The CloudEvent with Auth Context raised when a Firestore document is created,
/// updated or deleted.
class DocumentWrittenEventWithAuthContext extends $pb.GeneratedMessage {
  factory DocumentWrittenEventWithAuthContext({
    $0.DocumentEventData? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  DocumentWrittenEventWithAuthContext._();

  factory DocumentWrittenEventWithAuthContext.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DocumentWrittenEventWithAuthContext.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentWrittenEventWithAuthContext',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.events.cloud.firestore.v1'),
      createEmptyInstance: create)
    ..aOM<$0.DocumentEventData>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $0.DocumentEventData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentWrittenEventWithAuthContext clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentWrittenEventWithAuthContext copyWith(
          void Function(DocumentWrittenEventWithAuthContext) updates) =>
      super.copyWith((message) =>
              updates(message as DocumentWrittenEventWithAuthContext))
          as DocumentWrittenEventWithAuthContext;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentWrittenEventWithAuthContext create() =>
      DocumentWrittenEventWithAuthContext._();
  @$core.override
  DocumentWrittenEventWithAuthContext createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DocumentWrittenEventWithAuthContext getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          DocumentWrittenEventWithAuthContext>(create);
  static DocumentWrittenEventWithAuthContext? _defaultInstance;

  /// The data associated with the event.
  @$pb.TagNumber(1)
  $0.DocumentEventData get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($0.DocumentEventData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.DocumentEventData ensureData() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
