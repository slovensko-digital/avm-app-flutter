import 'package:basic_utils/basic_utils.dart' show TbsCertificate;
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../widgets/certificate_details.dart';

/// Dialog that contains [CertificateDetails] widget.
class CertificateDetailsDialog extends StatelessWidget {
  final TbsCertificate certificate;

  const CertificateDetailsDialog(this.certificate, {super.key});

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      child: Padding(
        padding: kScreenMargin,
        child: CertificateDetails(certificate: certificate),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: null,
        actions: const [CloseButton()],
      ),
      body: SafeArea(
        child: body,
      ),
    );
  }

  static Future<dynamic> show(
    BuildContext context,
    TbsCertificate certificate,
  ) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, __, ___) {
        return CertificateDetailsDialog(certificate);
      },
    );
  }
}
