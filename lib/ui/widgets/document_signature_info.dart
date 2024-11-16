import 'package:autogram_sign/autogram_sign.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../oids.dart';
import '../../strings_context.dart';
import '../../utils.dart';
import '../widgets/chip.dart' as avm;

typedef SigningCertificateQualification
    = DocumentValidationResponseBody$Signatures$Item$SigningCertificateQualification;
typedef _ValidationResult
    = DocumentValidationResponseBody$Signatures$ItemValidationResult;

/// Displays Document validation info based on provided [DocumentValidationResponseBody$Signatures$Item].
///
/// On left side, there is subject; validation result with qualification are
/// on right side.
class DocumentSignatureInfo extends StatelessWidget {
  final TbsCertificate certificate;
  final _ValidationResult validationResult;
  final SigningCertificateQualification qualification;
  final bool areQualifiedTimestamps;

  const DocumentSignatureInfo._({
    required this.certificate,
    required this.validationResult,
    required this.qualification,
    required this.areQualifiedTimestamps,
  });

  factory DocumentSignatureInfo(
    DocumentValidationResponseBody$Signatures$Item data,
  ) {
    final certDer = data.signingCertificate.certificateDer;
    final certificate = x509CertificateDataFromDer(certDer).tbsCertificate!;

    return DocumentSignatureInfo._(
      certificate: certificate,
      validationResult: data.validationResult,
      qualification: data.signingCertificate.qualification,
      areQualifiedTimestamps: data.areQualifiedTimestamps,
    );
  }

  @override
  Widget build(BuildContext context) {
    final subject = certificate.subject[X500Oids.cn] ?? '';
    final label = Text(
      subject,
      style: const TextStyle(fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: label),
        const SizedBox(width: 8),
        _buildChip(context),
      ],
    );
  }

  Widget _buildChip(BuildContext context) {
    final icon = switch (validationResult) {
      _ValidationResult.totalPassed => Icons.check,
      _ValidationResult.indeterminate => Icons.warning_amber_outlined,
      _ValidationResult.totalFailed => Icons.error_outline,
      _ => Icons.question_mark_outlined,
    };
    final foreground = switch (validationResult) {
      _ValidationResult.totalPassed => const Color(0xFF033608),
      _ValidationResult.indeterminate => const Color(0xFF4E2A00),
      _ValidationResult.totalFailed => const Color(0xFF4E0711),
      _ => Colors.black,
    };
    final background = switch (validationResult) {
      _ValidationResult.totalPassed => const Color(0xFFEDF5F3),
      _ValidationResult.indeterminate => const Color(0xFFF4F4EC),
      _ValidationResult.totalFailed => const Color(0xFFFBEEF0),
      _ => Colors.white,
    };
    final border = switch (validationResult) {
      _ValidationResult.totalPassed => const Color(0xFFA9D9CD),
      _ValidationResult.indeterminate => const Color(0xFFD5D6A2),
      _ValidationResult.totalFailed => const Color(0xFFC3112B),
      _ => Colors.grey,
    };

    return avm.Chip(
      label: _getLabel(context),
      foreground: foreground,
      background: background,
      border: border,
      leading: Icon(icon, color: foreground),
    );
  }

  String _getLabel(BuildContext context) {
    final strings = context.strings;

    return switch (validationResult) {
      _ValidationResult.totalFailed => strings.validationResultFailedLabel,
      _ValidationResult.indeterminate =>
        strings.validationResultIndeterminateLabel,
      _ValidationResult.swaggerGeneratedUnknown =>
        strings.validationResultUnknownLabel,
      _ValidationResult.totalPassed => switch (qualification) {
          SigningCertificateQualification.qesig => (!areQualifiedTimestamps
              ? strings.signatureQualificationQesigLabel
              : strings.signatureQualificationQesigWithQTLabel),
          SigningCertificateQualification.qeseal => (areQualifiedTimestamps
              ? strings.signatureQualificationQesealWithQTLabel
              : ""),
          SigningCertificateQualification.adesigQcQc => (areQualifiedTimestamps
              ? strings.signatureQualificationAdesigWithQTLabel
              : ""),
          _ => ""
          // TODO handle other cases properly
          // https://github.com/slovensko-digital/autogram/blob/748d17c4c8d1b14516dba76bbb8f7beaadbc1bf6/src/main/java/digital/slovensko/autogram/ui/gui/SignatureBadgeFactory.java#L116
        }
    };
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: '',
  type: DocumentSignatureInfo,
)
Widget previewDocumentSignatureInfo(BuildContext context) {
  final validationResult = _ValidationResult.values.byName(context.knobs.list(
    label: "Validation result",
    options: _ValidationResult.values.map((e) => e.name).toList(),
  ));
  final qualification =
      SigningCertificateQualification.values.byName(context.knobs.list(
    label: "Qualification",
    options: SigningCertificateQualification.values.map((e) => e.name).toList(),
  ));
  final areQualifiedTimestamps = context.knobs.boolean(label: "TS qualified");

  return DocumentSignatureInfo(
    DocumentValidationResponseBody$Signatures$Item(
      validationResult: validationResult,
      level:
          DocumentValidationResponseBody$Signatures$ItemLevel.xadesBaselineLta,
      claimedSigningTime: "2023-08-01T12:37:47 +0200",
      bestSigningTime: "2023-08-01T12:37:47 +0200",
      signingCertificate:
          DocumentValidationResponseBody$Signatures$Item$SigningCertificate(
        qualification: qualification,
        issuerDN:
            "OID.2.5.4.5=NTRCZ-26439395, O=\"První certifikační autorita, a.s.\", CN=I.CA Qualified CA/RSA 07/2015, C=CZ",
        subjectDN:
            "OID.2.5.4.5=ICA - 10432139, OID.2.5.4.97=NTRSK-00166073, CN=Ministerstvo spravodlivosti SR, O=Ministerstvo spravodlivosti SR, C=SK",
        certificateDer:
            "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",
      ),
      areQualifiedTimestamps: areQualifiedTimestamps,
      timestamps: const [
        DocumentValidationResponseBody$Signatures$Item$Timestamps$Item(
          qualification:
              DocumentValidationResponseBody$Signatures$Item$Timestamps$ItemQualification
                  .qtsa,
          timestampType:
              DocumentValidationResponseBody$Signatures$Item$Timestamps$ItemTimestampType
                  .signatureTimestamp,
          subjectDN:
              "CN=NASES Time Stamp Authority 2, O=Národná agentúra pre sieťové a elektronické služby, OID.2.5.4.97=NTRSK-42156424, OU=SNCA, C=SK",
          certificateDer:
              "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",
          productionTime: "2024-08-02T13:01:24 +0200",
        ),
      ],
    ),
  );
}
