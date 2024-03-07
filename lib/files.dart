import 'dart:io' show File;

import 'file_extensions.dart';

abstract class Files {
  /// Mapping of extension => MIME type.
  static const Map<String, String> _types = {
    "pdf": "application/pdf;base64",
    "jpg": "image/jpeg;base64",
    "jpeg": "image/jpeg;base64",
    "png": "image/png;base64",
    "txt": "text/plain;base64",
    "xml": "text/xml;base64",
    "sce": "application/vnd.etsi.asic-e+zip;base64",
    "asice": "application/vnd.etsi.asic-e+zip;base64",
    "asics": "application/vnd.etsi.asic-s+zip;base64",
    "p7m": "application/pkcs7-mime",
  };

  /// List of supported file types' extensions.
  static List<String> get supportedExtensions {
    return List.unmodifiable(_types.keys);
  }

  /// Gets the [file] Mime type.
  ///
  /// Throws [ArgumentError].
  static String getFileMimeType(File file) {
    final extension = file.extension.replaceFirst('.', '').toLowerCase();

    if (extension.isEmpty) {
      throw ArgumentError.value(file.basename, "file",
          "Cannot determine file type from file name without extension.");

      // https://pub.dev/packages/mime
      // https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
    }

    final type = _types[extension];

    if (type == null) {
      throw ArgumentError.value(file.basename, "file",
          "File type '${extension.toUpperCase()}' is not supported.");
    }

    return type;
  }
}
