import 'dart:convert' show latin1;
import 'dart:math' show max;
import 'dart:typed_data' show Uint8List;

import 'document_verification_exception.dart';

/// `/ByteRange` of a PAdES signature in PDF prepared for signing.
///
/// The PDF contains signature dictionary with `/Contents <00...00>` - empty
/// space for CMS signature. Signature covers all bytes of the PDF except of
/// this space: `[0, length1]` and `[offset2, offset2 + length2]`.
class PdfByteRange {
  final int length1;
  final int offset2;
  final int length2;

  const PdfByteRange._(this.length1, this.offset2, this.length2);

  /// Validates [byteRange] against the prepared [pdf]:
  ///  - it covers whole document except of the space for signature,
  ///  - the uncovered space is empty `/Contents` value of signature dictionary,
  ///  - it is the `/ByteRange` of the last signature in the PDF.
  factory PdfByteRange.validate(Uint8List pdf, List<int>? byteRange) {
    if (byteRange == null || byteRange.length != 4) {
      throw _invalid("expected 4 numbers");
    }

    final [offset1, length1, offset2, length2] = byteRange;
    if (offset1 != 0 ||
        length1 <= 0 ||
        offset2 <= length1 ||
        length2 < 0 ||
        offset2 + length2 != pdf.length) {
      throw _invalid("it does not cover whole document");
    }

    if (!_isEmptyHexString(pdf, length1, offset2)) {
      throw _invalid("uncovered bytes are not empty signature contents");
    }

    final before = latin1.decode(pdf.sublist(max(0, length1 - 32), length1));
    if (!RegExp(r"/Contents\s*$").hasMatch(before)) {
      throw _invalid("uncovered bytes are not signature contents");
    }

    if (!_isLastByteRange(pdf, byteRange)) {
      throw _invalid("it is not /ByteRange of the last signature");
    }

    return PdfByteRange._(length1, offset2, length2);
  }

  /// Gets the bytes covered by signature.
  Iterable<List<int>> coveredParts(Uint8List pdf) {
    return [
      Uint8List.sublistView(pdf, 0, length1),
      Uint8List.sublistView(pdf, offset2, offset2 + length2),
    ];
  }

  /// Whether `pdf[start:end]` is `<00..00>`.
  static bool _isEmptyHexString(Uint8List pdf, int start, int end) {
    const lessThan = 0x3C, greaterThan = 0x3E, zero = 0x30;

    if (end - start < 4 ||
        pdf[start] != lessThan ||
        pdf[end - 1] != greaterThan ||
        (end - start - 2).isOdd) {
      return false;
    }

    for (var i = start + 1; i < end - 1; i++) {
      if (pdf[i] != zero) return false;
    }

    return true;
  }

  static bool _isLastByteRange(Uint8List pdf, List<int> byteRange) {
    final matches = _byteRangePattern.allMatches(latin1.decode(pdf));
    if (matches.isEmpty) return false;

    final last = matches.last;
    final values = [for (var i = 1; i <= 4; i++) int.parse(last.group(i)!)];

    return values.indexed.every((entry) => entry.$2 == byteRange[entry.$1]);
  }

  static final _byteRangePattern = RegExp(
    r"/ByteRange\s*\[\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*\]",
  );

  static DocumentVerificationException _invalid(String message) {
    return DocumentVerificationException(
      DocumentVerificationFailure.unsupportedData,
      "Invalid PDF /ByteRange: $message.",
    );
  }
}
