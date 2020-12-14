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

// ignore: implementation_imports
import 'package:stagehand/src/common.dart';
import 'package:stagehand/stagehand.dart' as stagehand;

import '../command.dart';
import '../context.dart';
import '../directory.dart';

class GenerateCommand extends Command {
  @override
  final name = 'generate';

  @override
  final description = 'Generate a project to get started.';

  GenerateCommand(Context context) : super(context) {
    // Hidden option to generate into the current directory.
    argParser.addFlag('force', abbr: 'f', negatable: false, hide: true);

    // Hidden option to list available projects as JSON to stdout.
    argParser.addFlag('machine', negatable: false, hide: true);
  }

  @override
  Future<void> run() async {
    var options = argResults;

    // The `--machine` option emits the list of available generators to stdout
    // as JSON. This is useful for tools that don't want to have to parse the
    // output of `--help`. It's an undocumented command line flag, and may go
    // away or change.
    if (options['machine']) {
      return Future.sync(
          () => write(_createMachineInfo(context.generator.generators)));
    }

    if (options.rest.isEmpty) {
      usageException('No generator specified.');
    }

    if (options.rest.length >= 2) {
      usageException('Too many arguments (should only be one generator).');
    }

    var generatorName = options.rest.first;
    var generator = _getGenerator(generatorName);

    if (generator == null) {
      usageException("'$generatorName' is not a valid generator.\n");
    }

    if (!options['force'] && !await context.generator.cwd.isEmpty()) {
      warning(
          'The current directory is not empty. Overwritting an exising project is NOT recommended.\n'
          'Create a new (empty) project directory, or use --force to '
          "override this safeguard if you know what you're doing.");
      return Future.error(
          TargetDirectoryNotEmptyError('project directory not empty'));
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
      if (message != null && message.isNotEmpty) {
        message = message.trim();
        message = message.split('\n').map((line) => '--> $line').join('\n');
        write('\n$message');
      }
    });
  }

  stagehand.Generator _getGenerator(String id) {
    return context.generator.generators
        .firstWhere((g) => g.id == id, orElse: () => null);
  }

  String _createMachineInfo(List<stagehand.Generator> generators) {
    var itor = generators.map((stagehand.Generator generator) {
      var m = {
        'name': generator.id,
        'label': generator.label,
        'description': generator.description,
        'categories': generator.categories
      };

      if (generator.entrypoint != null) {
        m['entrypoint'] = generator.entrypoint.path;
      }

      return m;
    });
    return json.encode(itor.toList());
  }
}
