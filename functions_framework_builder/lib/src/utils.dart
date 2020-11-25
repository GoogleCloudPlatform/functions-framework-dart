import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

void validateHandlerShape(Element element) {
  if (element is! FunctionElement) {
    throw InvalidGenerationSourceError(
      'Only top-level functions are supported.',
      element: element,
    );
  }

  // TODO: validate that annotatedElement is "shape" of a shelf handler
  // GoogleCloudPlatform/functions-framework-dart#21
}
