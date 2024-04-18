import 'dart:io' show File;

import 'file_extensions.dart';

abstract class Files {
  /// Mapping of extension => MIME type.
  static const Map<String, String> _types = {
    "pdf": "application/pdf",
    "jpg": "image/jpeg",
    "jpeg": "image/jpeg",
    "png": "image/png",
    "txt": "text/plain",
    "xml": "text/xml",
    "sce": "application/vnd.etsi.asic-e+zip",
    "scs": "application/vnd.etsi.asic-s+zip",
    "asice": "application/vnd.etsi.asic-e+zip",
    "asics": "application/vnd.etsi.asic-s+zip",
    "p7m": "application/pkcs7-mime",
  };

  /// List of supported file types' extensions.
  static List<String> get supportedExtensions {
    return List.unmodifiable(_types.keys);
  }

  /// Gets the [file] Mime type or `null` when not known.
  static String? getFileMimeType(File file) {
    final extension = file.extension.replaceFirst('.', '').toLowerCase();

    if (extension.isEmpty) {
      throw ArgumentError.value(file.basename, "file",
          "Cannot determine file type from file name without extension.");

      // https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
      // https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types
    }

    return _types[extension];
  }
}
