// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import '../command.dart';
import '../context.dart';
import '../http_utils.dart';

class VersionCommand extends Command {
  @override
  final name = 'version';

  @override
  final description = 'Print the current version.';

  VersionCommand(Context context) : super(context) {
    argParser.addFlag('short',
        abbr: 's', negatable: false, help: 'Print just the version number.');
  }

  @override
  Future<void> run() async {
    await printVersion(context, short: argResults['short'], checkUpdates: true);
  }
}

/// Prints the current package version.
///
/// If [short] is true, prints just the version number.
/// If [checkUpdates] is true, also checks pub.dev for newer versions.
FutureOr<void> printVersion(Context context,
    {bool short, bool checkUpdates}) async {
  final name = context.app.name;
  final version = context.app.version;

  context.console.write(short
      ? version
      : 'Google Functions Framework for Dart CLI ($name) version: $version');
  if (!checkUpdates) return;

  return Future(() async {
    // TODO: Don't say a "later" version is available in certain situations.
    // For example: when current version is "0.3.0-dev" and latest published is
    // "0.2.0".
    var latest = await checkPubForLaterVersion('functions_framework', version);
    if (latest != null) {
      context.console.write(
          'Version $latest is available! To update to this version, run: '
          '`pub global activate $name`.');
    }
  });
}
