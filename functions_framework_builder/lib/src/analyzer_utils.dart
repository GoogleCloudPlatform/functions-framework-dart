import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtension on DartType {
  String toStringNonNullable() {
    final val = getDisplayString();
    if (val.endsWith('?')) return val.substring(0, val.length - 1);
    return val;
  }
}

extension ElementExtension on Element {
  String toStringNonNullable() {
    final val = getDisplayString();
    if (val.endsWith('?')) return val.substring(0, val.length - 1);
    return val;
  }
}
