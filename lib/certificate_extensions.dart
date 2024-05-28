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
}
