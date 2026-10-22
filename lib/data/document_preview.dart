import 'dart:typed_data' show Uint8List;

/// Document visualized on the device from the data objects covered by the
/// signature.
///
/// See also:
///  - [CreateDocumentPreviewUseCase]
sealed class DocumentPreview {
  const DocumentPreview();
}

class PdfDocumentPreview extends DocumentPreview {
  final Uint8List data;

  const PdfDocumentPreview(this.data);
}

class ImageDocumentPreview extends DocumentPreview {
  final Uint8List data;

  const ImageDocumentPreview(this.data);
}

class TextDocumentPreview extends DocumentPreview {
  final String text;

  const TextDocumentPreview(this.text);
}

/// HTML document or e-form transformed to HTML.
class HtmlDocumentPreview extends DocumentPreview {
  final String html;

  const HtmlDocumentPreview(this.html);
}

/// Document of type, which can't be visualized on the device, or with content,
/// which doesn't match its type.
class UnsupportedDocumentPreview extends DocumentPreview {
  final String mimeType;

  const UnsupportedDocumentPreview(this.mimeType);
}
