import 'dart:typed_data' show Uint8List;

import 'document_verification_exception.dart';

/// DER encoded CMS signed attributes - data to sign of CAdES and PAdES
/// signatures.
///
/// Only `message-digest` attribute is needed for verification. Parsing is
/// strict, so the bytes can't be interpreted differently by a validator.
class CmsSignedAttributes {
  static const _setTag = 0x31;
  static const _sequenceTag = 0x30;
  static const _oidTag = 0x06;
  static const _octetStringTag = 0x04;

  /// DER encoded OID 1.2.840.113549.1.9.4 (id-messageDigest).
  static const _messageDigestOid = [
    0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x09, 0x04, //
  ];

  /// Value of the `message-digest` attribute - digest of the signed content.
  final Uint8List messageDigest;

  const CmsSignedAttributes._(this.messageDigest);

  /// Parses DER encoded `SET OF Attribute`.
  factory CmsSignedAttributes.parse(Uint8List data) {
    final set = _DerElement.read(data, 0);
    if (set.tag != _setTag || set.end != data.length) {
      throw _malformed("expected SET of attributes");
    }

    final seenTypes = <String>{};
    Uint8List? messageDigest;
    var offset = set.contentStart;

    while (offset < set.end) {
      final attribute = _DerElement.read(data, offset, set.end);
      if (attribute.tag != _sequenceTag) {
        throw _malformed("expected Attribute SEQUENCE");
      }

      final type = _DerElement.read(
        data,
        attribute.contentStart,
        attribute.end,
      );
      final values = _DerElement.read(data, type.end, attribute.end);
      if (type.tag != _oidTag ||
          values.tag != _setTag ||
          values.end != attribute.end) {
        throw _malformed("expected Attribute type and values");
      }

      final typeBytes = data.sublist(type.contentStart, type.end);
      if (!seenTypes.add(typeBytes.join("."))) {
        throw _malformed("duplicate attribute");
      }

      if (_equals(typeBytes, _messageDigestOid)) {
        final value = _DerElement.read(data, values.contentStart, values.end);
        if (value.tag != _octetStringTag || value.end != values.end) {
          throw _malformed("expected single message-digest OCTET STRING");
        }

        messageDigest = data.sublist(value.contentStart, value.end);
      }

      offset = attribute.end;
    }

    if (messageDigest == null) {
      throw _malformed("missing message-digest attribute");
    }

    return CmsSignedAttributes._(messageDigest);
  }

  static bool _equals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  static DocumentVerificationException _malformed(String message) {
    return DocumentVerificationException(
      DocumentVerificationFailure.unsupportedData,
      "Malformed CMS signed attributes: $message.",
    );
  }
}

/// DER TLV element - only low tag numbers and definite minimal lengths.
class _DerElement {
  final int tag;
  final int contentStart;
  final int end;

  const _DerElement(this.tag, this.contentStart, this.end);

  static _DerElement read(Uint8List data, int offset, [int? limit]) {
    limit ??= data.length;
    if (offset + 2 > limit) {
      throw CmsSignedAttributes._malformed("unexpected end of data");
    }

    final tag = data[offset];
    if (tag & 0x1F == 0x1F) {
      throw CmsSignedAttributes._malformed("unsupported high tag number");
    }

    var length = data[offset + 1];
    var contentStart = offset + 2;

    if (length & 0x80 != 0) {
      final count = length & 0x7F;
      // indefinite length (0x80) is not allowed in DER
      if (count == 0 || count > 4 || contentStart + count > limit) {
        throw CmsSignedAttributes._malformed("invalid length");
      }

      length = 0;
      for (var i = 0; i < count; i++) {
        length = (length << 8) | data[contentStart + i];
      }
      contentStart += count;

      // DER requires the shortest encoding
      if (length < 0x80 || data[offset + 2] == 0) {
        throw CmsSignedAttributes._malformed("non-minimal length");
      }
    }

    final end = contentStart + length;
    if (end > limit) {
      throw CmsSignedAttributes._malformed("length exceeds data");
    }

    return _DerElement(tag, contentStart, end);
  }
}
