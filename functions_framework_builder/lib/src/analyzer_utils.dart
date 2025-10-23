import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtension on DartType {
  String toStringNonNullable() => getDisplayString().dropQuestion();
}

extension ElementExtension on Element {
  String toStringNonNullable() => displayString().dropQuestion();
}

extension on String {
  String dropQuestion() {
    if (endsWith('?')) return substring(0, length - 1);
    return this;
  }
}
