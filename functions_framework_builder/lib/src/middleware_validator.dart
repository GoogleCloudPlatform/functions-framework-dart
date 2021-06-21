import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'supported_function_type.dart';

import 'supported_middleware_type.dart';

class MiddlewareValiator {
  final SupportedMiddlewareType _type;

  MiddlewareValiator._(this._type);

  FactoryData validate(
    LibraryElement library,
    String targetName,
    FunctionElement element,
  ) {
    final reference = _type.createReference(library, targetName, element);
    if (reference != null) {
      return reference;
    }

    throw InvalidGenerationSourceError(
      '''
Not compatible with a supported function shape:
${_type.typedefName} [${_type.typeDescription}] from ${_type.libraryUri}
''',
      element: element,
    );
  }

  static Future<MiddlewareValiator> create(Resolver resolver) async =>
      MiddlewareValiator._(
        await SupportedMiddlewareType.create(
          resolver,
          'package:shelf/shelf.dart',
          'Middleware',
          'MiddlewareTarget',
        ),
      );
}
