import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../certificate_extensions.dart';
import '../../oids.dart';
import 'certificate_picker.dart';

/// [Certificate] item for [CertificatePicker].
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

    return RadioListTile(
      value: certificate.certIndex,
      groupValue: selectedCertificate?.certIndex,
      onChanged: (final int? value) {
        if (value != null) {
          onCertificateChanged(certificate);
        }
      },
      title: Text(
        certificate.usageLabel ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Text(cert.issuer[X500Oids.cn] ?? ''),
          //Text("Slot: ${certificate.slot}"),
          Text("Sériové číslo: ${cert.serialNumber.toRadixString(16)}"),
          Text("Platný do: ${_dateFormat.format(cert.validity.notAfter)}"),
          Text("Celé meno: ${cert.subject[X500Oids.cn]}"),
          Text("Identifikátor: ${cert.subject[X500Oids.sn]}"),
        ],
      ),
    );
  }
}
