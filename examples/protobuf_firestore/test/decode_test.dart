import 'package:example_protobuf_firestore/src/function_types.dart';
import 'package:test/test.dart';

import 'test_shared.dart';

void main() {
  test('validate protobuf decode', () {
    final instance = DocumentEventData.fromBuffer(protobytes);

    expect(instance.toProto3Json(), jsonOutput);
  });
}
