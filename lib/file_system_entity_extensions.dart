import 'dart:io' show FileSystemEntity;

import 'package:path/path.dart' as path;

import 'directory_extensions.dart';
import 'file_extensions.dart';

/// Set of extensions on [FileSystemEntity] type.
///
/// See also:
///  - [FileExtensions]
///  - [DirectoryExtensions]
extension FileSystemEntityExtensions on FileSystemEntity {
  /// Calls [path.extension] on this [FileSystemEntity.path].
  String get extension => path.extension(this.path);

  /// Calls [path.basename] on this [FileSystemEntity.path].
  String get basename => path.basename(this.path);

  /// Calls [path.basenameWithoutExtension] on this [FileSystemEntity.path].
  String get basenameWithoutExtension =>
      path.basenameWithoutExtension(this.path);
}
