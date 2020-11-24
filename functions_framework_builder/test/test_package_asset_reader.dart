// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:stream_transform/stream_transform.dart';

// Copied from https://github.com/dart-lang/build/blob/8fbdb405f17ff20a8391cb454d40e8cc32fe2883/build_test/lib/src/package_reader.dart
// TODO: remove this when https://github.com/dart-lang/build/issues/2923 is fixed
class TestPackageAssetReader extends AssetReader
    implements MultiPackageAssetReader {
  final PackageConfig _packageConfig;

  /// What package is the originating build occurring in.
  final String _rootPackage;

  /// Wrap a [PackageConfig] to identify where files are located.
  ///
  /// To use a normal [PackageConfig] use `Isolate.packageConfig` and
  /// `loadPackageConfigUri`:
  ///
  /// ```
  /// new PackageAssetReader(
  ///   await loadPackageConfigUri(await Isolate.packageConfig));
  /// ```
  TestPackageAssetReader(this._packageConfig, [this._rootPackage]);

  /// A reader that can resolve files known to the current isolate.
  ///
  /// A [rootPackage] should be provided for full API compatibility.
  static Future<TestPackageAssetReader> currentIsolate(
          {String rootPackage}) async =>
      TestPackageAssetReader(
          await findPackageConfigUri(await Isolate.packageConfig), rootPackage);

  File _resolve(AssetId id) {
    final uri = id.uri;
    if (uri.isScheme('package')) {
      final uri = _packageConfig.resolve(id.uri);
      if (uri != null) {
        return File.fromUri(uri);
      }
    }
    if (id.package == _rootPackage) {
      return File(p.canonicalize(p.join(_rootPackagePath, id.path)));
    }
    return null;
  }

  String get _rootPackagePath {
    // If the root package has a pub layout, use `packagePath`.
    final root = _packageConfig[_rootPackage]?.root?.toFilePath();
    if (root != null && Directory(p.join(root, 'lib')).existsSync()) {
      return root;
    }
    // Assume the cwd is the package root.
    return p.current;
  }

  @override
  Stream<AssetId> findAssets(Glob glob, {String package}) {
    package ??= _rootPackage;
    if (package == null) {
      throw UnsupportedError(
          'Root package must be provided to use `findAssets` without an '
          'explicit `package`.');
    }
    final packageLibDir = _packageConfig[package]?.packageUriRoot;
    if (packageLibDir == null) {
      return const Stream.empty();
    }

    var packageFiles = Directory.fromUri(packageLibDir)
        .list(recursive: true)
        .whereType<File>()
        .map((f) =>
            p.join('lib', p.relative(f.path, from: p.fromUri(packageLibDir))));
    if (package == _rootPackage) {
      packageFiles = packageFiles.merge(Directory(_rootPackagePath)
          .list(recursive: true)
          .whereType<File>()
          .map((f) => p.relative(f.path, from: _rootPackagePath))
          .where((p) => !(p.startsWith('packages/') || p.startsWith('lib/'))));
    }
    return packageFiles.where(glob.matches).map((p) => AssetId(package, p));
  }

  @override
  Future<bool> canRead(AssetId id) =>
      _resolve(id)?.exists() ?? Future.value(false);

  @override
  Future<List<int>> readAsBytes(AssetId id) =>
      _resolve(id)?.readAsBytes() ?? (throw AssetNotFoundException(id));

  @override
  Future<String> readAsString(AssetId id, {Encoding encoding = utf8}) =>
      _resolve(id)?.readAsString(encoding: encoding) ??
      (throw AssetNotFoundException(id));
}

void printBetter(String expectedContent) => print(
      ["r'''\n", LineSplitter.split(expectedContent).join('\n'), "'''"].join(),
    );
