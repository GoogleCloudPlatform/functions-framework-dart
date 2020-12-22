import 'dart:io';

import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

const defaultPort = 8080;

final _listeningPattern = RegExp(r'Listening on :(\d+)');

int _autoPort;

int get autoPort => _autoPort;

Future<TestProcess> startServerTest({
  bool shouldFail = false,
  int expectedListeningPort = defaultPort,
  Map<String, String> env,
  Iterable<String> arguments = const <String>[],
}) async {
  if (expectedListeningPort == 0) {
    expect(arguments, isNot(contains('--port')));
    if (env != null) {
      expect(env, isNot(contains('PORT')));
    }
  }
  final args = [
    'bin/server.dart',
    ...arguments,
    if (expectedListeningPort == 0) ...['--port', '0'],
  ];
  final proc = await TestProcess.start('dart', args, environment: env);

  if (!shouldFail) {
    final output = await proc.stdout.next;
    final match = _listeningPattern.firstMatch(output);
    expect(match, isNotNull);
    _autoPort = int.parse(match[1]);
    if (expectedListeningPort == 0) {
      expect(_autoPort, greaterThan(0));
    } else {
      expect(_autoPort, expectedListeningPort);
    }
  }

  return proc;
}

Future<void> finishServerTest(
  TestProcess proc, {
  ProcessSignal signal = ProcessSignal.sigterm,
  Object requestOutput,
}) async {
  requestOutput ??= finishedPattern('GET', 200);
  await expectLater(
    proc.stdout,
    requestOutput is StreamMatcher
        ? requestOutput
        : emitsThrough(requestOutput),
  );
  proc.signal(signal);
  await proc.shouldExit(0);
  await expectLater(
    proc.stdout,
    emitsThrough('Received signal $signal - closing'),
  );
}

RegExp finishedPattern(String method, int statusCode) =>
    RegExp('$method.+\[${statusCode.toString()}\]');
