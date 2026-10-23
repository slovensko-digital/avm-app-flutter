import 'dart:convert' show base64Decode, utf8;
import 'dart:typed_data' show Uint8List;

import 'package:autogram_sign/autogram_sign.dart'
    show DocumentVisualizationResponseBody, VerifiableVisualizationResponseBody;
import 'package:flutter/foundation.dart' show compute, visibleForTesting;
import 'package:injectable/injectable.dart';

import '../data/document_preview.dart';
import '../verification/data_to_sign_verifier.dart';

/// Creates [DocumentPreview] of the document to sign.
///
/// Simple documents - PDF, plain text and PNG or JPEG image - are visualized
/// on the device from the data object covered by the signature, so the
/// visualization doesn't have to be trusted from the server. Other documents,
/// e.g. e-forms, can be visualized only by the trusted server, see
/// [fromServerVisualization].
@lazySingleton
class CreateDocumentPreviewUseCase {
  /// Creates preview of the document from its signed data object, or
  /// [UnsupportedDocumentPreview] when it can't be visualized on the device.
  Future<DocumentPreview> call(
    VerifiableVisualizationResponseBody visualization,
  ) {
    return compute(createDocumentPreview, visualization);
  }

  /// Creates preview from the [visualization] created by the server.
  Future<DocumentPreview> fromServerVisualization(
    DocumentVisualizationResponseBody visualization,
  ) {
    return compute(createServerVisualizationPreview, visualization);
  }

  @visibleForTesting
  static DocumentPreview createDocumentPreview(
    VerifiableVisualizationResponseBody visualization,
  ) {
    final document = visualization.document;
    final data = decodeSignedDataObject(document);
    final (type, charset) = _parseMimeType(document.mimeType);

    // content must match the type, so it can't be visualized differently
    // than other applications would display the signed document
    final preview = switch (type) {
      "application/pdf" when _startsWith(data, "%PDF-".codeUnits) =>
        PdfDocumentPreview(data),
      "image/png" when _startsWith(data, _pngSignature) => ImageDocumentPreview(
        data,
      ),
      "image/jpeg" when _startsWith(data, _jpegSignature) =>
        ImageDocumentPreview(data),
      "text/plain" when charset == null || _utf8Charsets.contains(charset) =>
        _textPreview(data),
      _ => null,
    };

    return preview ?? UnsupportedDocumentPreview(type);
  }

  @visibleForTesting
  static DocumentPreview createServerVisualizationPreview(
    DocumentVisualizationResponseBody visualization,
  ) {
    final mimeType = visualization.mimeType;
    final content = visualization.content;

    // Drop spaces from Mime-Type
    return switch (mimeType.replaceAll(" ", "")) {
      "application/pdf;base64" => PdfDocumentPreview(base64Decode(content)),
      "text/plain;base64" || "text/plain;charset=UTF-8;base64" =>
        TextDocumentPreview(utf8.decode(base64Decode(content))),
      "text/html;base64" => HtmlDocumentPreview(
        utf8.decode(base64Decode(content)),
      ),
      "text/plain" ||
      "text/plain;charset=UTF-8" => TextDocumentPreview(content),
      _ => UnsupportedDocumentPreview(mimeType),
    };
  }

  /// Parses media type and charset from the [mimeType] - e.g.
  /// `text/plain; charset=UTF-8;base64`.
  static (String type, String? charset) _parseMimeType(String mimeType) {
    final [type, ...parameters] = mimeType.split(";");
    String? charset;

    for (final parameter in parameters) {
      final [name, ...value] = parameter.split("=");

      if (name.trim().toLowerCase() == "charset") {
        charset = value.join("=").replaceAll('"', "").trim().toLowerCase();
      }
    }

    return (type.trim().toLowerCase(), charset);
  }

  /// Decodes UTF-8 text; `null` when it's not valid, as the text wouldn't be
  /// visualized as it's signed.
  static DocumentPreview? _textPreview(Uint8List data) {
    final String text;

    try {
      text = utf8.decode(data);
    } on FormatException {
      return null;
    }

    // UTF-8 BOM
    return TextDocumentPreview(
      text.startsWith("﻿") ? text.substring(1) : text,
    );
  }

  static const _utf8Charsets = {"utf-8", "utf8"};
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
