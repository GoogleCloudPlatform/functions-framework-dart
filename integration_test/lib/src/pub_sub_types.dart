// Copyright 2021 Google LLC
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

import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

part 'pub_sub_types.g.dart';

@JsonSerializable()
class PubSub {
  final PubSubMessage message;
  final String subscription;

  PubSub(this.message, this.subscription);

  factory PubSub.fromJson(Map<String, dynamic> json) => _$PubSubFromJson(json);

  Map<String, dynamic> toJson() => _$PubSubToJson(this);
}

@JsonSerializable()
class PubSubMessage {
  final String data;
  final Map<String, String> attributes;
  final String messageId;
  final DateTime publishTime;

  Uint8List dataBytes() => base64Decode(data);

  PubSubMessage(this.data, this.messageId, this.publishTime, this.attributes);

  factory PubSubMessage.fromJson(Map<String, dynamic> json) =>
      _$PubSubMessageFromJson(json);

  Map<String, dynamic> toJson() => _$PubSubMessageToJson(this);
}
