import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../certificate_extensions.dart';
import '../../oids.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import 'certificate_picker.dart';

/// [CertificatePicker] item do display [certificate] info:
///  - Subject CN, LN, C
///  - Subject SN
///  - Issuer CN
///  - Not After
class CertificatePickerItem extends StatelessWidget {
  static final DateFormat _dateFormat = DateFormat("dd.MM.yyyy");

  final Certificate certificate;
  final Certificate? selectedCertificate;
  final ValueChanged<Certificate> onCertificateChanged;

  const CertificatePickerItem({
    super.key,
    required this.certificate,
    required this.selectedCertificate,
    required this.onCertificateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cert = certificate.tbsCertificate;

    final strings = context.strings;

    final title = cert.subject[X500Oids.cn] ?? '';
    final identity = "${cert.subject[X500Oids.sn]}";
    final issuer = strings.certificateIssuer("${cert.issuer[X500Oids.cn]}");
    final validTo =
        strings.certificateNotAfter(_dateFormat.format(cert.validity.notAfter));

    // NOT using RadioListTile because need to scale-up and style Radio

    return ListTile(
      onTap: () {
        onCertificateChanged(certificate);
      },
      leading: Transform.scale(
        scale: kRadioScale,
        child: Radio<int>(
          value: certificate.certIndex,
          groupValue: selectedCertificate?.certIndex,
          onChanged: (_) {
            onCertificateChanged(certificate);
          },
          activeColor: kRadioActiveColor,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(identity),
          Text(issuer),
          Text(validTo),
        ],
      ),
    );
  }
}
