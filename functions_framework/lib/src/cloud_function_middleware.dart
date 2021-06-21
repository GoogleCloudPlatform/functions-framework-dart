import 'package:meta/meta_meta.dart';

@Target({TargetKind.function})
class CloudFunctionMiddleware {
  final String? target;
  const CloudFunctionMiddleware({this.target});
}
