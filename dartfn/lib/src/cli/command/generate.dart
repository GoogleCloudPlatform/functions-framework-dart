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
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';

import '../../stagehand/common.dart';
import '../../stagehand/stagehand.dart' as stagehand;
import '../command.dart';
import '../directory.dart';

class GenerateCommand extends Command {
  @override
  final name = 'generate';

  @override
  final description = 'Run a project generator to get started.';

  GenerateCommand(super.context) {
    argParser.addFlag('list',
        negatable: false, help: 'List available generators.');

    // Hidden option to list available projects as JSON to stdout.
    // This is useful for tools that don't want to have to parse the output of
    // `--help`.
    argParser.addFlag('machine', negatable: false, hide: true);

    // Hidden option to generate into the current directory.
    argParser.addFlag('force', abbr: 'f', negatable: false, hide: true);
  }

  @override
  String get usage => 'Usage: ${context.app.name} generate [generator]';

  @override
  Future<void> run() async {
    final generators = context.generator.generators;
    final options = argResults!;

    if (options['machine']) {
      return write(_createMachineInfo(generators));
    }

    if (options['list']!) {
      return _listGenerators(generators);
    }

    if (options.rest.isEmpty) {
      error('No generator specified.');
      write();
      return _listGenerators(generators);
    }

    if (options.rest.length >= 2) {
      usageException('Too many arguments (should only be one generator).');
    }

    var generatorName = options.rest.first;
    if (!options['force'] && !await context.generator.cwd.isEmpty()) {
      return error(
          'The current directory is not empty. Overwritting an exising project '
          'is NOT recommended.\n'
          'Create a new (empty) project directory, or use --force to override '
          "this safeguard if you know what you're doing.");
    }

    return await _generate(generatorName);
  }

  Future<void> _generate(String generatorName) {
    var generator = _getGenerator(generatorName);
    if (generator == null) {
      usageException("'$generatorName' is not a valid generator.\n");
    }

    var projectName = context.generator.cwd.basename();
    projectName = normalizeProjectName(projectName);

    write('project: $projectName');

    final target = context.generator.target ??
        DirectoryGeneratorTarget(context.console.out, context.generator.cwd);

    write('Creating $generatorName application `$projectName`:');

    var vars = <String, String>{};

    var f = generator.generate(projectName, target, additionalVars: vars);
    return f.then((_) {
      write('${generator.numFiles()} files written.');

      var message = generator.getInstallInstructions();
      if (message.isNotEmpty) {
        message = message.trim();
        message = message.split('\n').map((line) => '--> $line').join('\n');
        write('\n$message');
      }
    });
  }

  String _createMachineInfo(List<stagehand.Generator> generators) {
    var itor = generators.map(
      (stagehand.Generator generator) => {
        'name': generator.id,
        'description': generator.description,
        if (generator.entrypoint != null)
          'entrypoint': generator.entrypoint!.path,
      },
    );
    return json.encode(itor.toList());
  }

  void _listGenerators(List<stagehand.Generator> generators) {
    write('Available generators:');

    final generators = context.generator.generators;
    final len = generators.fold(0, (int length, g) => max(length, g.id.length));
    generators
        .map((g) => '  ${g.id.padRight(len)} - ${g.description}')
        .forEach(write);
  }

  stagehand.Generator? _getGenerator(String id) =>
      context.generator.generators.singleWhereOrNull((g) => g.id == id);
}
