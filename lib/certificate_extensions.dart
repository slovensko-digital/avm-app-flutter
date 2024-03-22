import 'package:basic_utils/basic_utils.dart';
import 'package:eidmsdk/types.dart';

import 'utils.dart' as utils;

/// A set of extensions on [Certificate] type.
extension CertificateExtensions on Certificate {
  /// Gets the [TbsCertificate].
  TbsCertificate get tbsCertificate {
    final x509CertificateData = utils.x509CertificateDataFromDer(certData);

    return x509CertificateData.tbsCertificate!;
  }

  /// Gets the usage label text.
  String? get usageLabel {
    // Issuer SN: SVK eID ACA2 / SVK eID PCA / SVK eID SCA
    // Slot: QES / ES
    // keyUsage: KeyUsage.NON_REPUDIATION / KeyUsage.KEY_ENCIPHERMENT / KeyUsage.DATA_ENCIPHERMENT
    // extKeyUsage: null / ExtendedKeyUsage.CLIENT_AUTH / null

    final cert = tbsCertificate;
    final keyUsage = cert.extensions?.keyUsage;

    if (isQualified) {
      return "Kvalifikovaný certifikát pre elektronický podpis";
    }

    if (keyUsage == null) {
      return null;
    }

    if (keyUsage.contains(KeyUsage.DIGITAL_SIGNATURE)) {
      return "Certifikát pre elektronický podpis";
    }

    if (keyUsage.contains(KeyUsage.DATA_ENCIPHERMENT)) {
      return "Šifrovací certifikát";
    }

    return keyUsage
        .map((e) => e.name.toLowerCase().replaceAll('_', ' '))
        .join(", ");
  }
}
