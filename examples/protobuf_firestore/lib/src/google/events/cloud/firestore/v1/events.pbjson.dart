//
//  Generated code. Do not modify.
//  source: google/events/cloud/firestore/v1/events.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use documentCreatedEventDescriptor instead')
const DocumentCreatedEvent$json = {
  '1': 'DocumentCreatedEvent',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.events.cloud.firestore.v1.DocumentEventData',
      '10': 'data'
    },
  ],
  '7': {},
};

/// Descriptor for `DocumentCreatedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List documentCreatedEventDescriptor = $convert.base64Decode(
    'ChREb2N1bWVudENyZWF0ZWRFdmVudBJHCgRkYXRhGAEgASgLMjMuZ29vZ2xlLmV2ZW50cy5jbG'
    '91ZC5maXJlc3RvcmUudjEuRG9jdW1lbnRFdmVudERhdGFSBGRhdGE6V7L42CwqZ29vZ2xlLmNs'
    'b3VkLmZpcmVzdG9yZS5kb2N1bWVudC52MS5jcmVhdGVkyvjYLAhkYXRhYmFzZcr42CwJbmFtZX'
    'NwYWNlyvjYLAhkb2N1bWVudA==');

@$core.Deprecated('Use documentUpdatedEventDescriptor instead')
const DocumentUpdatedEvent$json = {
  '1': 'DocumentUpdatedEvent',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.events.cloud.firestore.v1.DocumentEventData',
      '10': 'data'
    },
  ],
  '7': {},
};

/// Descriptor for `DocumentUpdatedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List documentUpdatedEventDescriptor = $convert.base64Decode(
    'ChREb2N1bWVudFVwZGF0ZWRFdmVudBJHCgRkYXRhGAEgASgLMjMuZ29vZ2xlLmV2ZW50cy5jbG'
    '91ZC5maXJlc3RvcmUudjEuRG9jdW1lbnRFdmVudERhdGFSBGRhdGE6V7L42CwqZ29vZ2xlLmNs'
    'b3VkLmZpcmVzdG9yZS5kb2N1bWVudC52MS51cGRhdGVkyvjYLAhkYXRhYmFzZcr42CwJbmFtZX'
    'NwYWNlyvjYLAhkb2N1bWVudA==');

@$core.Deprecated('Use documentDeletedEventDescriptor instead')
const DocumentDeletedEvent$json = {
  '1': 'DocumentDeletedEvent',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.events.cloud.firestore.v1.DocumentEventData',
      '10': 'data'
    },
  ],
  '7': {},
};

/// Descriptor for `DocumentDeletedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List documentDeletedEventDescriptor = $convert.base64Decode(
    'ChREb2N1bWVudERlbGV0ZWRFdmVudBJHCgRkYXRhGAEgASgLMjMuZ29vZ2xlLmV2ZW50cy5jbG'
    '91ZC5maXJlc3RvcmUudjEuRG9jdW1lbnRFdmVudERhdGFSBGRhdGE6V7L42CwqZ29vZ2xlLmNs'
    'b3VkLmZpcmVzdG9yZS5kb2N1bWVudC52MS5kZWxldGVkyvjYLAhkYXRhYmFzZcr42CwJbmFtZX'
    'NwYWNlyvjYLAhkb2N1bWVudA==');

@$core.Deprecated('Use documentWrittenEventDescriptor instead')
const DocumentWrittenEvent$json = {
  '1': 'DocumentWrittenEvent',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.events.cloud.firestore.v1.DocumentEventData',
      '10': 'data'
    },
  ],
  '7': {},
};

/// Descriptor for `DocumentWrittenEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List documentWrittenEventDescriptor = $convert.base64Decode(
    'ChREb2N1bWVudFdyaXR0ZW5FdmVudBJHCgRkYXRhGAEgASgLMjMuZ29vZ2xlLmV2ZW50cy5jbG'
    '91ZC5maXJlc3RvcmUudjEuRG9jdW1lbnRFdmVudERhdGFSBGRhdGE6V7L42CwqZ29vZ2xlLmNs'
    'b3VkLmZpcmVzdG9yZS5kb2N1bWVudC52MS53cml0dGVuyvjYLAhkYXRhYmFzZcr42CwJbmFtZX'
    'NwYWNlyvjYLAhkb2N1bWVudA==');

@$core.Deprecated('Use documentCreatedEventWithAuthContextDescriptor instead')
const DocumentCreatedEventWithAuthContext$json = {
  '1': 'DocumentCreatedEventWithAuthContext',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.events.cloud.firestore.v1.DocumentEventData',
      '10': 'data'
    },
  ],
  '7': {},
};

/// Descriptor for `DocumentCreatedEventWithAuthContext`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List documentCreatedEventWithAuthContextDescriptor =
    $convert.base64Decode(
        'CiNEb2N1bWVudENyZWF0ZWRFdmVudFdpdGhBdXRoQ29udGV4dBJHCgRkYXRhGAEgASgLMjMuZ2'
        '9vZ2xlLmV2ZW50cy5jbG91ZC5maXJlc3RvcmUudjEuRG9jdW1lbnRFdmVudERhdGFSBGRhdGE6'
        'f7L42Cw6Z29vZ2xlLmNsb3VkLmZpcmVzdG9yZS5kb2N1bWVudC52MS5jcmVhdGVkLndpdGhBdX'
        'RoQ29udGV4dMr42CwIZGF0YWJhc2XK+NgsCW5hbWVzcGFjZcr42CwIZG9jdW1lbnTK+NgsCGF1'
        'dGh0eXBlyvjYLAZhdXRoaWQ=');

@$core.Deprecated('Use documentUpdatedEventWithAuthContextDescriptor instead')
const DocumentUpdatedEventWithAuthContext$json = {
  '1': 'DocumentUpdatedEventWithAuthContext',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.events.cloud.firestore.v1.DocumentEventData',
      '10': 'data'
    },
  ],
  '7': {},
};

/// Descriptor for `DocumentUpdatedEventWithAuthContext`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List documentUpdatedEventWithAuthContextDescriptor =
    $convert.base64Decode(
        'CiNEb2N1bWVudFVwZGF0ZWRFdmVudFdpdGhBdXRoQ29udGV4dBJHCgRkYXRhGAEgASgLMjMuZ2'
        '9vZ2xlLmV2ZW50cy5jbG91ZC5maXJlc3RvcmUudjEuRG9jdW1lbnRFdmVudERhdGFSBGRhdGE6'
        'f7L42Cw6Z29vZ2xlLmNsb3VkLmZpcmVzdG9yZS5kb2N1bWVudC52MS51cGRhdGVkLndpdGhBdX'
        'RoQ29udGV4dMr42CwIZGF0YWJhc2XK+NgsCW5hbWVzcGFjZcr42CwIZG9jdW1lbnTK+NgsCGF1'
        'dGh0eXBlyvjYLAZhdXRoaWQ=');

@$core.Deprecated('Use documentDeletedEventWithAuthContextDescriptor instead')
const DocumentDeletedEventWithAuthContext$json = {
  '1': 'DocumentDeletedEventWithAuthContext',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.events.cloud.firestore.v1.DocumentEventData',
      '10': 'data'
    },
  ],
  '7': {},
};

/// Descriptor for `DocumentDeletedEventWithAuthContext`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List documentDeletedEventWithAuthContextDescriptor =
    $convert.base64Decode(
        'CiNEb2N1bWVudERlbGV0ZWRFdmVudFdpdGhBdXRoQ29udGV4dBJHCgRkYXRhGAEgASgLMjMuZ2'
        '9vZ2xlLmV2ZW50cy5jbG91ZC5maXJlc3RvcmUudjEuRG9jdW1lbnRFdmVudERhdGFSBGRhdGE6'
        'f7L42Cw6Z29vZ2xlLmNsb3VkLmZpcmVzdG9yZS5kb2N1bWVudC52MS5kZWxldGVkLndpdGhBdX'
        'RoQ29udGV4dMr42CwIZGF0YWJhc2XK+NgsCW5hbWVzcGFjZcr42CwIZG9jdW1lbnTK+NgsCGF1'
        'dGh0eXBlyvjYLAZhdXRoaWQ=');

@$core.Deprecated('Use documentWrittenEventWithAuthContextDescriptor instead')
const DocumentWrittenEventWithAuthContext$json = {
  '1': 'DocumentWrittenEventWithAuthContext',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.events.cloud.firestore.v1.DocumentEventData',
      '10': 'data'
    },
  ],
  '7': {},
};

/// Descriptor for `DocumentWrittenEventWithAuthContext`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List documentWrittenEventWithAuthContextDescriptor =
    $convert.base64Decode(
        'CiNEb2N1bWVudFdyaXR0ZW5FdmVudFdpdGhBdXRoQ29udGV4dBJHCgRkYXRhGAEgASgLMjMuZ2'
        '9vZ2xlLmV2ZW50cy5jbG91ZC5maXJlc3RvcmUudjEuRG9jdW1lbnRFdmVudERhdGFSBGRhdGE6'
        'f7L42Cw6Z29vZ2xlLmNsb3VkLmZpcmVzdG9yZS5kb2N1bWVudC52MS53cml0dGVuLndpdGhBdX'
        'RoQ29udGV4dMr42CwIZGF0YWJhc2XK+NgsCW5hbWVzcGFjZcr42CwIZG9jdW1lbnTK+NgsCGF1'
        'dGh0eXBlyvjYLAZhdXRoaWQ=');
