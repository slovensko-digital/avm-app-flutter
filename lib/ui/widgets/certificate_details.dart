import 'package:basic_utils/basic_utils.dart' show TbsCertificate;
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../oids.dart';
import '../../strings_context.dart';
import '../../utils.dart';

/// Displays X509 Certificate details:
///  - Issued to (Subject)
///  - Issued by
///  - Validity
class CertificateDetails extends StatelessWidget {
  final TbsCertificate certificate;

  const CertificateDetails({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    final children = [
      _buildHeadline(strings.certificateSubjectLabel),
      ..._buildSubjectInfo(certificate.subject),
      _buildHeadline(strings.certificateIssuerLabel),
      ..._buildSubjectInfo(certificate.issuer),
      _buildHeadline(strings.certificateValidityLabel),
      _Info(strings.certificateValidityNotBeforeLabel,
          certificate.validity.notBefore.toString()),
      _Info(strings.certificateValidityNotAfterLabel,
          certificate.validity.notAfter.toString()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildHeadline(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  List<Widget> _buildSubjectInfo(Map<String, String?> data) {
    return <Widget>[
      _Info("Common name (CN)", data[X500Oids.cn]),
      _Info("Organization (O)", data[X500Oids.on]),
      _Info("Locality name (LN)", data[X500Oids.ln]),
      _Info("Country (C)", data[X500Oids.c]),
      _Info("Serial number (SN)", data[X500Oids.sn]),
    ];
  }
}

/// Wrapped row with [label] on the left and [value] on the right.
class _Info extends StatelessWidget {
  final String label;
  final String? value;

  const _Info(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(width: 160, child: Text(label)),
          Text(value ?? ''),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'CertificateDetails',
  type: CertificateDetails,
)
Widget previewCertificateDetails(BuildContext context) {
  const certDer =
      "MIIH5TCCBc2gAwIBAgIEALfsWjANBgkqhkiG9w0BAQsFADB9MQswCQYDVQQGEwJDWjEmMCQGA1UEAwwdSS5DQSBRdWFsaWZpZWQgQ0EvUlNBIDA3LzIwMTUxLTArBgNVBAoMJFBydm7DrSBjZXJ0aWZpa2HEjW7DrSBhdXRvcml0YSwgYS5zLjEXMBUGA1UEBRMOTlRSQ1otMjY0MzkzOTUwHhcNMjIwOTIwMTExMTAxWhcNMjMwOTIwMTExMTAxWjCBkTELMAkGA1UEBhMCU0sxJzAlBgNVBAoMHk1pbmlzdGVyc3R2byBzcHJhdm9kbGl2b3N0aSBTUjEnMCUGA1UEAwweTWluaXN0ZXJzdHZvIHNwcmF2b2RsaXZvc3RpIFNSMRcwFQYDVQRhDA5OVFJTSy0wMDE2NjA3MzEXMBUGA1UEBRMOSUNBIC0gMTA0MzIxMzkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCWG6O21F/DSe4QCHnkElUAcqmNshPiW6d05gWUnbq8RwqRyMJJ5lZxNvAmcgB0ob8v34Z2TBLfV/vpx81wXJQd/xTvqp/tgTIAoBZrmpBYXJAQJLVXxWihWgHCJFCuPKowFpFcVwrQ6NbINvbXPyuIgWJ/gN4w35I9ipQCslgJWajJNtuF+hQWMvLm11NuY8rBIg4cHGGEgtu8SgqhNY8+NMaILTKpNb3jtP/ITVOCl6cp3wA5TOYPGyXb/pCHVHmnBGehUAs1+BDf1urfTcavZspXU/dTR1ErOiw+pjYQhb6qj+bNX0TqFgsaaXCB8/6GLL5lmVE6SziwZTkCdv6BAgMBAAGjggNWMIIDUjAjBgNVHREEHDAaoBgGCisGAQQBgbhIBAagCgwIMTA0MzIxMzkwDgYDVR0PAQH/BAQDAgbAMIIBLgYDVR0gBIIBJTCCASEwMAYNKwYBBAGBuEgKAVsBATAfMB0GCCsGAQUFBwIBFhFodHRwOi8vd3d3LmljYS5jejCB4QYNK4EekZmEBQAAAAECAjCBzzCBzAYIKwYBBQUHAgIwgb8MgbxFTjogVGhpcyBpcyBhIHF1YWxpZmllZCBjZXJ0aWZpY2F0ZSBmb3IgZWxlY3Ryb25pYyBzZWFsIGFjY29yZGluZyB0byBSZWd1bGF0aW9uIChFVSkgTm8gOTEwLzIwMTQuIFNLOiBLdmFsaWZpa292YW55IGNlcnRpZmlrYXQgcHJlIGVsZWt0cm9uaWNrdSBwZWNhdCB2IHN1bGFkZSBzIG5hcmlhZGVuaW0gKEVVKSBjLjkxMC8yMDE0LjAJBgcEAIvsQAEDMIGMBgNVHR8EgYQwgYEwKaAnoCWGI2h0dHA6Ly9xY3JsZHAxLmljYS5jei9xY2ExNV9yc2EuY3JsMCmgJ6AlhiNodHRwOi8vcWNybGRwMi5pY2EuY3ovcWNhMTVfcnNhLmNybDApoCegJYYjaHR0cDovL3FjcmxkcDMuaWNhLmN6L3FjYTE1X3JzYS5jcmwwgZIGCCsGAQUFBwEDBIGFMIGCMAgGBgQAjkYBATAIBgYEAI5GAQQwVwYGBACORgEFME0wLRYnaHR0cHM6Ly93d3cuaWNhLmN6L1pwcmF2eS1wcm8tdXppdmF0ZWxlEwJjczAcFhZodHRwczovL3d3dy5pY2EuY3ovUERTEwJlbjATBgYEAI5GAQYwCQYHBACORgEGAjBlBggrBgEFBQcBAQRZMFcwKwYIKwYBBQUHMAKGH2h0dHA6Ly9xLmljYS5jei9xY2ExNXNrX3JzYS5wN2MwKAYIKwYBBQUHMAGGHGh0dHA6Ly9vY3NwLmljYS5jei9xY2ExNV9yc2EwCQYDVR0TBAIwADAdBgNVHQ4EFgQUZnA9DYix8Eh4k/Q/zdAD88y3Y+MwHwYDVR0jBBgwFoAUbIEnWTPiopohGIspFLw4bdRzeT0wEwYDVR0lBAwwCgYIKwYBBQUHAwQwDQYJKoZIhvcNAQELBQADggIBANgEAV4KCWPyH+2NB8JAc9rUiE+zDHMZO31ovV8FHiDUthcoghwgPhC4ufM5pDpgB73GMuGLA1vv0VqEH6jRAWsU9l8qobGYuBcmHaHCY79zLXCMSpwlQu5nlbOPUr5FqgtIWal7m2uHRrVJrK96VWtLALeFn18PPBwK2ylhWjoKCtwehLmKwaYnefROR2R2DbaRL+Wp6SXu9lDY7itsRBtRzZ7bJooji05609wWlWsmAYLT7KNXCzpYCFBu8DOY6HGNUbM1f5JU+BfiI7ITIGQeipx8uQymko8vEhaEXLR1oNtWdjo5hPPYiUMrUMK3hiXd29k9npsr1BWJC+RGzJSu/la6TEOxK/MUtkVtXZzWib1IS1JugGsn8mdJoHgRXOPBuX84PybEuRy/INl8PAXPP6dYkN4niIh1iVV+NQoCpP2C13XApd7uzssCFbMAlVUyAlNShookOXZs2js7d0yrnM1HTuyrxtfZV7D8rSqsKxZK0feRlU/di4/Zv+9+pdLBZQWWB0Ej7gRdHmIDPIwW0EduCIeffLCGLhz8/yPdvlfIexDoL6RGjtC4ptFwrfI7QT6/er27Q1XOyu9WkASDQi04KNkHLZ/MPgOdwk1816bDW/NtY0k1pdJ/1HEDUvTC+HdWJt0HxAPwrBprnXFj2u/b1Cv9jxVxW1bub5R6";
  final cert = x509CertificateDataFromDer(certDer).tbsCertificate!;

  return CertificateDetails(certificate: cert);
}
