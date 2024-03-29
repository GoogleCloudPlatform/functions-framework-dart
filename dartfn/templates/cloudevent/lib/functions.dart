import 'dart:convert';
import 'dart:io';

import 'package:functions_framework/functions_framework.dart';

const _encoder = JsonEncoder();

@CloudFunction()
void function(CloudEvent event, RequestContext context) {
  context.logger
      .info('[CloudEvent] source: ${event.source}, subject: ${event.subject}');
  stderr.writeln(
    _encoder.convert(
      {
        'message': event,
        'severity': LogSeverity.info,
      },
    ),
  );
}
