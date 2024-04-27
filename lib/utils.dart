import 'dart:convert' show base64Url;
import 'dart:math' show Random;

import 'package:basic_utils/basic_utils.dart'
    show X509CertificateData, X509Utils;

final Random _random = Random.secure();

/// Creates cryptographic random data encoded as base64.
String createCryptoRandomString([int length = 32]) {
  final values = List<int>.generate(length, (i) => _random.nextInt(256));

  return base64Url.encode(values);
}

/// Loads [X509CertificateData] from ASN.1 DER [data].
X509CertificateData x509CertificateDataFromDer(String data) {
  assert(data.isNotEmpty);

  final base64Value = data.replaceAll('\n', '');
  final pem = [
    X509Utils.BEGIN_CERT,
    base64Value,
    X509Utils.END_CERT,
  ].join("\n");

  return X509Utils.x509CertificateFromPem(pem);
}
