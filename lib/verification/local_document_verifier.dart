import 'dart:typed_data' show Uint8List;

import 'package:archive/archive.dart' show Archive, ZipDecoder;
import 'package:autogram_sign/autogram_sign.dart'
    show
        VerifiableVisualizationResponseBody,
        VerifiableVisualizationResponseBodySignatureForm;

import 'data_to_sign_verifier.dart';
import 'document_verification_exception.dart';
import 'xml_data_container.dart';

/// Verifies, that the document visualized from
/// [VerifiableVisualizationResponseBody] is the document selected by the user.
///
/// This is possible only when the user signs local document - document from
/// other system (e.g. integration) is available only from the server.
abstract class LocalDocumentVerifier {
  /// Verifies [visualization] against the [localDocument] content.
  ///
  /// Throws [DocumentVerificationException] when the verification fails.
  static void verify(
    VerifiableVisualizationResponseBody visualization,
    Uint8List localDocument,
  ) {
    final document = decodeSignedDataObject(visualization.document);

    if (visualization.signatureForm ==
        VerifiableVisualizationResponseBodySignatureForm.pades) {
      // PDF prepared for signing is incremental update of the local PDF;
      // the added revision is visualized too
      final byteRange = visualization.pdfByteRange;
      if (_startsWith(document, localDocument) &&
          byteRange != null &&
          byteRange.length == 4 &&
          byteRange[1] >= localDocument.length) {
        return;
      }

      throw _mismatch();
    }

    if (_equals(document, localDocument)) {
      return;
    }

    // signature is added to already signed ASiC container, the visualized
    // document is the signed document inside
    if (_isZip(localDocument)) {
      final filename = visualization.document.filename;
      final entry = filename == null
          ? null
          : _decodeZip(localDocument)?.findFile(filename);

      if (entry != null && entry.isFile && _equals(entry.content, document)) {
        return;
      }
    }

    // XML Datacontainer is created by the server from the selected XML e-form
    if (XmlDataContainer.isXmlDataContainerMimeType(
          visualization.document.mimeType,
        ) &&
        XmlDataContainer.parse(document).containsForm(localDocument)) {
      return;
    }

    throw _mismatch();
  }

  static bool _isZip(Uint8List data) {
    return _startsWith(data, const [0x50, 0x4B, 0x03, 0x04]);
  }

  static Archive? _decodeZip(Uint8List data) {
    try {
      return ZipDecoder().decodeBytes(data);
    } catch (_) {
      return null;
    }
  }

  static bool _startsWith(List<int> data, List<int> prefix) {
    if (data.length < prefix.length) return false;

    for (var i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) return false;
    }

    return true;
  }

  static bool _equals(List<int> a, List<int> b) {
    return a.length == b.length && _startsWith(a, b);
  }

  static DocumentVerificationException _mismatch() {
    return const DocumentVerificationException(
      DocumentVerificationFailure.localDocumentMismatch,
      "Visualized document is not the selected document.",
    );
  }
}
