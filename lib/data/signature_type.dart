import 'pdf_signing_option.dart';

/// Represents options how to sign PDF.
///
/// See also:
///  - [PdfSigningOption]
enum SignatureType {
  /// Without timestamp.
  withoutTimestamp(false),

  /// With timestamp.
  withTimestamp(true);

  /// Whether to add the timestamp.
  final bool addTimestamp;

  const SignatureType(this.addTimestamp);
}
