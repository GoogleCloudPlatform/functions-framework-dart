import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';
import 'package:source_gen/source_gen.dart';

void validateHandlerShape(Element element) {
  if (element is! FunctionElement) {
    throw InvalidGenerationSourceError(
      'Only top-level functions are supported.',
      element: element,
    );
  }

  final func = element as FunctionElement;

  @alwaysThrows
  void notCompatible() => throw InvalidGenerationSourceError(
        'Not compatible with package:shelf handler "$_handlerShape"',
        element: element,
      );

  if (func.parameters.isEmpty) {
    notCompatible();
  }

  final firstParam = func.parameters.first;
  if (!firstParam.isPositional) {
    notCompatible();
  }

  if (func.parameters.skip(1).any((element) => element.isRequiredPositional)) {
    notCompatible();
  }

  if (!_requestChecker.isExactlyType(firstParam.type)) {
    notCompatible();
  }

  final returnType = func.returnType;

  if (_responseChecker.isAssignableFromType(returnType)) {
    return;
  }

  if (returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr) {
    final interface = returnType as InterfaceType;

    if (_responseChecker.isAssignableFromType(interface.typeArguments.single)) {
      return;
    }
  }

  notCompatible();
}

const _handlerShape = 'FutureOr<Response> Function(Request request)';

const _requestChecker = TypeChecker.fromRuntime(Request);
const _responseChecker = TypeChecker.fromRuntime(Response);
