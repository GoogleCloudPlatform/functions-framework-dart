import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_helper/source_helper.dart';
import 'constants.dart';
import 'supported_function_type.dart';

class SupportedMiddlewareType {
  final String libraryUri;
  final String typedefName;
  final String typeDescription;

  final FunctionType _type;

  SupportedMiddlewareType._(
    this.libraryUri,
    this.typedefName,
    this._type,
  ) : typeDescription = _type.getDisplayString(withNullability: false);

  static Future<SupportedMiddlewareType> create(
    Resolver resolver,
    String libraryUri,
    String typeDefName,
    String constructor,
  ) async {
    final lib = await resolver.libraryFor(
      AssetId.resolve(Uri.parse(libraryUri)),
    );

    final handlerTypeAlias =
        lib.exportNamespace.get(typeDefName) as TypeAliasElement;

    final functionType = handlerTypeAlias.instantiate(
      typeArguments: [],
      nullabilitySuffix: NullabilitySuffix.none,
    );

    return SupportedMiddlewareType._(
      libraryUri,
      typeDefName,
      functionType as FunctionType,
    );
  }

  FactoryData? createReference(
    LibraryElement library,
    String targetName,
    FunctionElement element,
  ) {
    if (element.library.typeSystem.isSubtypeOf(element.type, _type)) {
      return TrivialFactoryData(
        escapeDartString(targetName),
        '$functionsLibraryPrefix.${element.name}',
      );
    }
    return null;
  }
}
