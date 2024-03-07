import 'package:autogram_sign/autogram_sign.dart' show SigningParametersLevel;

/// Represents options how to sign PDF.
enum PdfSigningOption {
  /// PAdES
  pades("PAdES", SigningParametersLevel.padesBaselineB),

  /// XAdES ASiC-E
  xades("XAdES ASiC-E", SigningParametersLevel.xadesBaselineB),

  /// CAdES ASiC-E
  cades("CAdES ASiC-E", SigningParametersLevel.cadesBaselineB);

  final String label;
  final SigningParametersLevel level;

  const PdfSigningOption(this.label, this.level);
}
