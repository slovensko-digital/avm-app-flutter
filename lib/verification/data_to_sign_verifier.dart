import 'dart:convert' show base64;
import 'dart:typed_data' show Uint8List;

import 'package:autogram_sign/autogram_sign.dart'
    show
        SignedDataObject,
        VerifiableVisualizationResponseBody,
        VerifiableVisualizationResponseBodySignatureForm;

import 'cms_signed_attributes.dart';
import 'data_object_reference.dart';
import 'digest_algorithm.dart';
import 'document_verification_exception.dart';
import 'pdf_byte_range.dart';

/// Verifies, that data to sign returned by the server contains digest of the
/// document visualized from [VerifiableVisualizationResponseBody], so the
/// signature will cover exactly the visualized document.
///
/// Thus the client doesn't have to trust the server, which computes the data
/// to sign.
abstract class DataToSignVerifier {
  /// Verifies base64 encoded [dataToSign] against the [visualization].
  ///
  /// Throws [DocumentVerificationException] when the verification fails.
  static void verify(
    VerifiableVisualizationResponseBody visualization,
    String dataToSign,
  ) {
    final data = decodeBase64(dataToSign, "data to sign");
    final document = decodeSignedDataObject(visualization.document);

    switch (visualization.signatureForm) {
      case VerifiableVisualizationResponseBodySignatureForm.xades:
        // ds:SignedInfo references the document directly
        final reference = DataObjectReference.fromSignedInfo(data);
        _verifyReference(reference, visualization.document, document);

      case VerifiableVisualizationResponseBodySignatureForm.cades:
        final messageDigest = CmsSignedAttributes.parse(data).messageDigest;
        final manifest = visualization.asicManifest;

        if (manifest == null) {
          // CMS without ASiC-E container digests the document itself
          _verifyMessageDigest(messageDigest, [document]);
        } else {
          // CMS digests ASiC manifest, which references the document
          final manifestContent = decodeSignedDataObject(manifest);
          _verifyMessageDigest(messageDigest, [manifestContent]);

          final reference = DataObjectReference.fromAsicManifest(
            manifestContent,
          );
          _verifyReference(reference, visualization.document, document);
        }

      case VerifiableVisualizationResponseBodySignatureForm.pades:
        if (!_startsWith(document, "%PDF-".codeUnits)) {
          throw const DocumentVerificationException(
            DocumentVerificationFailure.unsupportedData,
            "PAdES document is not PDF.",
          );
        }

        // CMS digests the byte range of the PDF prepared for signing
        final byteRange = PdfByteRange.validate(
          document,
          visualization.pdfByteRange,
        );
        final messageDigest = CmsSignedAttributes.parse(data).messageDigest;
        _verifyMessageDigest(messageDigest, byteRange.coveredParts(document));

      case VerifiableVisualizationResponseBodySignatureForm
          .swaggerGeneratedUnknown:
        throw const DocumentVerificationException(
          DocumentVerificationFailure.unsupportedData,
          "Unknown signature form.",
        );
    }
  }

  static void _verifyReference(
    DataObjectReference reference,
    SignedDataObject dataObject,
    Uint8List content,
  ) {
    if (reference.uri != dataObject.filename) {
      throw DocumentVerificationException(
        DocumentVerificationFailure.dataToSignMismatch,
        "Signed data object '${reference.uri}' is not the visualized document "
        "'${dataObject.filename}'.",
      );
    }

    final digest = reference.digestAlgorithm.digest([content]);
    if (!_equals(digest, reference.digestValue)) {
      throw DocumentVerificationException(
        DocumentVerificationFailure.dataToSignMismatch,
        "Digest of '${reference.uri}' doesn't match the visualized document.",
      );
    }
  }

  static void _verifyMessageDigest(
    Uint8List messageDigest,
    Iterable<List<int>> content,
  ) {
    final algorithm = DigestAlgorithm.fromDigestLength(messageDigest.length);
    final digest = algorithm.digest(content);

    if (!_equals(digest, messageDigest)) {
      throw const DocumentVerificationException(
        DocumentVerificationFailure.dataToSignMismatch,
        "Message digest doesn't match the visualized document.",
      );
    }
  }

  static bool _startsWith(List<int> data, List<int> prefix) {
    return data.length >= prefix.length &&
        _equals(data.sublist(0, prefix.length), prefix);
  }

  static bool _equals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;

    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }

    return difference == 0;
  }
}

/// Decodes base64 content of the [dataObject].
Uint8List decodeSignedDataObject(SignedDataObject dataObject) {
  return decodeBase64(dataObject.content, "content of ${dataObject.filename}");
}

/// Decodes base64 [value] of [what].
Uint8List decodeBase64(String value, String what) {
  try {
    return base64.decode(value);
  } on FormatException {
    throw DocumentVerificationException(
      DocumentVerificationFailure.unsupportedData,
      "Invalid base64 encoded $what.",
    );
  }
}
