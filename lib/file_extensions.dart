import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Set of extensions on [File] type.
extension FileExtensions on File {
  /// Calls [path.extension] on this [File].
  String get extension => path.extension(this.path);

  /// Calls [path.basename] on this [File].
  String get basename => path.basename(this.path);

  /// Calls [path.basenameWithoutExtension] on this [File].
  String get basenameWithoutExtension =>
      path.basenameWithoutExtension(this.path);

  /// Returns redacted file info usable for logging.
  ///
  /// In case of [kDebugMode], full [File.path] is returned;
  /// "???.[FileExtensions.extension]" otherwise.
  String get redactedInfo => (kDebugMode ? this.path : "???$extension");
}
