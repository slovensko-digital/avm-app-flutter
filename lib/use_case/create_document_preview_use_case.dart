import 'dart:convert' show utf8;
import 'dart:typed_data' show Uint8List;

import 'package:autogram_sign/autogram_sign.dart'
    show
        VerifiableVisualizationResponseBody,
        VerifiableVisualizationTransformation;
import 'package:flutter/foundation.dart' show compute, visibleForTesting;
import 'package:injectable/injectable.dart';

import '../data/document_preview.dart';
import '../verification/data_to_sign_verifier.dart';
import '../verification/xml_data_container.dart';
import '../xslt/xslt.dart';

/// Creates [DocumentPreview] from [VerifiableVisualizationResponseBody] - the
/// document is visualized on the device, so the visualization doesn't have to
/// be trusted from the server.
///
/// XML Datacontainer is transformed by its XSLT, which is verified against the
/// digest in the XML Datacontainer. The XML Datacontainer itself is verified
/// later against the data to sign.
@lazySingleton
class CreateDocumentPreviewUseCase {
  Future<DocumentPreview> call(
    VerifiableVisualizationResponseBody visualization,
  ) {
    return compute(createDocumentPreview, visualization);
  }

  @visibleForTesting
  static DocumentPreview createDocumentPreview(
    VerifiableVisualizationResponseBody visualization,
  ) {
    final document = visualization.document;
    final data = decodeSignedDataObject(document);

    if (XmlDataContainer.isXmlDataContainerMimeType(document.mimeType)) {
      return _xmlDataContainerPreview(data, visualization.transformation);
    }

    final mimeType = document.mimeType.split(";").first.trim().toLowerCase();

    // content must match the type, so it can't be visualized differently
    // than other applications would display the signed document
    return switch (mimeType) {
      "application/pdf" when _startsWith(data, "%PDF-".codeUnits) =>
        PdfDocumentPreview(data),
      "image/png" when _startsWith(data, _pngSignature) => ImageDocumentPreview(
        data,
      ),
      "image/jpeg" when _startsWith(data, _jpegSignature) =>
        ImageDocumentPreview(data),
      "text/plain" => TextDocumentPreview(_decodeText(data)),
      "application/xml" || "text/xml" => TextDocumentPreview(
        _prettyXml(_decodeText(data)),
      ),
      _ => UnsupportedDocumentPreview(mimeType),
    };
  }

  static DocumentPreview _xmlDataContainerPreview(
    Uint8List data,
    VerifiableVisualizationTransformation? transformation,
  ) {
    final xdc = XmlDataContainer.parse(data);
    final embedded = xdc.embeddedTransformation;

    XsltProcessor? processor;
    try {
      if (embedded != null) {
        processor = XsltProcessor.fromElement(embedded);
      } else if (xdc.transformationDigest != null && transformation != null) {
        final xslt = decodeBase64(transformation.content, "transformation");
        xdc.verifyTransformation(xslt);
        processor = XsltProcessor.parse(utf8.decode(xslt));
      }

      if (processor != null) {
        final result = processor.transformElement(xdc.formData);
        final destination =
            xdc.mediaDestinationTypeDescription ??
            (result.method == OutputMethod.text ? "TXT" : "HTML");

        return destination == "TXT"
            ? TextDocumentPreview(result.content)
            : HtmlDocumentPreview(result.content);
      }
    } on XsltException {
      // e-form XSLT uses features, which are not supported on the device
    }

    // visualize at least the e-form data covered by the signature
    return TextDocumentPreview(xdc.formData.toXmlString(pretty: true));
  }

  static String _decodeText(Uint8List data) {
    final text = utf8.decode(data, allowMalformed: true);
    return text.startsWith("﻿") ? text.substring(1) : text;
  }

  static String _prettyXml(String xml) {
    try {
      return parseXml(xml).toXmlString(pretty: true);
    } on Exception {
      return xml;
    }
  }

  static const _pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  static const _jpegSignature = [0xFF, 0xD8, 0xFF];

  static bool _startsWith(List<int> data, List<int> prefix) {
    if (data.length < prefix.length) return false;

    for (var i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) return false;
    }

    return true;
  }
}
