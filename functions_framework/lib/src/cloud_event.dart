// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'cloud_event.g.dart';

@JsonSerializable(includeIfNull: false, checked: true)
class CloudEvent {
  @JsonKey(required: true)
  final String id;
  @JsonKey(required: true)
  final Uri source;

  @JsonKey(name: 'specversion', required: true)
  final String specVersion;
  @JsonKey(required: true)
  final String type;

  @JsonKey(name: 'datacontenttype')
  final String dataContentType;
  final Object data;

  @JsonKey(name: 'dataschema')
  final Uri dataSchema;
  final String subject;
  final DateTime time;

  CloudEvent({
    @required this.id,
    @required this.source,
    @required this.specVersion,
    @required this.type,
    this.data,
    this.dataContentType,
    this.dataSchema,
    this.subject,
    this.time,
  });

  factory CloudEvent.fromJson(Map<String, dynamic> json) =>
      _$CloudEventFromJson(json);

  Map<String, dynamic> toJson() => _$CloudEventToJson(this);
}
