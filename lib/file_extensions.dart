import 'dart:io' show File;

import 'package:flutter/foundation.dart';

import 'file_system_entity_extensions.dart';

/// Set of extensions on [File] type.
extension FileExtensions on File {
  /// Returns redacted file info usable for logging.
  ///
  /// In case of [kDebugMode], full [File.path] is returned;
  /// "???.[FileExtensions.extension]" otherwise.
  String get redactedInfo => (kDebugMode ? path : "???$extension");
}
