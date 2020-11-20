import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/iso_8601_duration_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import '../../cloudevent.dart';

part 'serializers.g.dart';

@SerializersFor([
  CloudEvent,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(Iso8601DateTimeSerializer())
      ..add(Iso8601DurationSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
