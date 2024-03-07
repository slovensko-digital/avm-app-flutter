import 'dart:convert' show base64Url;
import 'dart:io' show File;
import 'dart:math' show Random;

import 'package:basic_utils/basic_utils.dart'
    show X509CertificateData, X509Utils;

import 'file_extensions.dart';

class Utils {
  static final Random _random = Random.secure();

  /// Creates cryptographic random data encoded as base64.
  // TODO Rename function and let the caller encode it into base64
  static String createCryptoRandomString([int length = 32]) {
    final values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }

  /// Gets the [file] Mime type.
  ///
  /// Throws [ArgumentError].
  static String getFileMimeType(File file) {
    final extension = file.extension.replaceFirst('.', '').toLowerCase();

    if (extension.isEmpty) {
      throw ArgumentError.value(file, "file",
          "Cannot determine file type from file name without extension.");

      // https://pub.dev/packages/mime
    }

    return switch (extension) {
      "pdf" => "application/pdf;base64",
      "txt" => "text/plain;base64",
      "xml" => "text/xml;base64",
      "jpg" || "jpeg" => "image/jpeg;base64",
      "png" => "image/png;base64",
      _ => throw ArgumentError.value(file, "file",
          "File type '${extension.toUpperCase()}' is not supported."),
    };
  }

  /// Loads [X509CertificateData] from ASN.1 DER [data].
  static X509CertificateData x509CertificateDataFromDer(String data) {
    assert(data.isNotEmpty);

    final base64Value = data.replaceAll('\n', '');
    final pem = [
      X509Utils.BEGIN_CERT,
      base64Value,
      X509Utils.END_CERT,
    ].join("\n");

    return X509Utils.x509CertificateFromPem(pem);
  }
}
