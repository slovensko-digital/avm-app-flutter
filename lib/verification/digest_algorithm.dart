import 'package:crypto/crypto.dart' as crypto;

import 'document_verification_exception.dart';

/// Digest algorithms accepted in data to sign.
///
/// Weak algorithms (e.g. SHA-1) are intentionally not supported, so the
/// server can't make the client sign a document colliding with the visualized
/// one.
enum DigestAlgorithm {
  sha256(
    32,
    "http://www.w3.org/2001/04/xmlenc#sha256",
    "2.16.840.1.101.3.4.2.1",
  ),
  sha384(
    48,
    "http://www.w3.org/2001/04/xmldsig-more#sha384",
    "2.16.840.1.101.3.4.2.2",
  ),
  sha512(
    64,
    "http://www.w3.org/2001/04/xmlenc#sha512",
    "2.16.840.1.101.3.4.2.3",
  )
  ;

  /// Length of the digest in bytes.
  final int length;

  /// XML DSig `DigestMethod` algorithm URI.
  final String xmlDsigUri;

  /// Object identifier.
  final String oid;

  const DigestAlgorithm(this.length, this.xmlDsigUri, this.oid);

  /// Gets the algorithm by its XML DSig `DigestMethod` algorithm [uri].
  static DigestAlgorithm fromXmlDsigUri(String? uri) {
    return values.firstWhere(
      (algorithm) => algorithm.xmlDsigUri == uri,
      orElse: () => throw _unsupported("XML DSig digest method $uri"),
    );
  }

  /// Gets the algorithm by `urn:oid:` [urn] used in XML Datacontainer.
  static DigestAlgorithm fromOidUrn(String? urn) {
    return values.firstWhere(
      (algorithm) => "urn:oid:${algorithm.oid}" == urn,
      orElse: () => throw _unsupported("digest method $urn"),
    );
  }

  /// Gets the algorithm by [length] of the digest in bytes.
  ///
  /// CMS signed attributes contain only the digest value, its algorithm is
  /// determined by the length.
  static DigestAlgorithm fromDigestLength(int length) {
    return values.firstWhere(
      (algorithm) => algorithm.length == length,
      orElse: () => throw _unsupported("digest of $length bytes"),
    );
  }

  /// Computes digest of all [parts] concatenated.
  List<int> digest(Iterable<List<int>> parts) {
    final hash = switch (this) {
      sha256 => crypto.sha256,
      sha384 => crypto.sha384,
      sha512 => crypto.sha512,
    };
    final output = _DigestSink();
    final input = hash.startChunkedConversion(output);

    for (final part in parts) {
      input.add(part);
    }
    input.close();

    return output.value.bytes;
  }

  static DocumentVerificationException _unsupported(String what) {
    return DocumentVerificationException(
      DocumentVerificationFailure.unsupportedData,
      "Unsupported $what.",
    );
  }
}

class _DigestSink implements Sink<crypto.Digest> {
  late crypto.Digest value;

  @override
  void add(crypto.Digest data) {
    value = data;
  }

  @override
  void close() {}
}
