import 'dart:convert' show base64, jsonDecode, utf8;
import 'dart:io' show File;

import 'package:autogram/data/document_preview.dart';
import 'package:autogram/use_case/create_document_preview_use_case.dart';
import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixtures created by AVM server, see the `document_verification_test.dart`.
const _fixtures = "test/verification/fixtures";

/// Tests for the [CreateDocumentPreviewUseCase] class.
void main() {
  group('CreateDocumentPreviewUseCase.createDocumentPreview', () {
    const createDocumentPreview =
        CreateDocumentPreviewUseCase.createDocumentPreview;

    test('visualizes PDF document', () {
      final visualization = _loadVisualization("pades_pdf");

      final preview = createDocumentPreview(visualization);

      expect(
        preview,
        isA<PdfDocumentPreview>().having(
          (preview) => preview.data,
          "data",
          base64.decode(visualization.document.content),
        ),
      );
    });

    test('visualizes plain text document', () {
      final preview = createDocumentPreview(_loadVisualization("xades_txt"));

      expect(
        preview,
        isA<TextDocumentPreview>().having(
          (preview) => preview.text,
          "text",
          File("$_fixtures/doc.txt").readAsStringSync(),
        ),
      );
    });

    test('visualizes PNG and JPEG images', () {
      final png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00];
      final jpeg = [0xFF, 0xD8, 0xFF, 0xE0, 0x00];

      expect(
        createDocumentPreview(_visualization("image/png;base64", png)),
        isA<ImageDocumentPreview>(),
      );
      expect(
        createDocumentPreview(_visualization("image/jpeg;base64", jpeg)),
        isA<ImageDocumentPreview>(),
      );
      expect(
        createDocumentPreview(_visualization("image/png;base64", jpeg)),
        isA<UnsupportedDocumentPreview>(),
      );
    });

    test('does not visualize e-form', () {
      final preview = createDocumentPreview(_loadVisualization("xades_xdc"));

      expect(
        preview,
        isA<UnsupportedDocumentPreview>().having(
          (preview) => preview.mimeType,
          "mimeType",
          "application/vnd.gov.sk.xmldatacontainer+xml",
        ),
      );
    });

    test('does not visualize document with content of other type', () {
      final visualization = _loadVisualization("xades_txt");
      final preview = createDocumentPreview(
        visualization.copyWith(
          document: visualization.document.copyWith(
            mimeType: "application/pdf;base64",
          ),
        ),
      );

      expect(
        preview,
        isA<UnsupportedDocumentPreview>().having(
          (preview) => preview.mimeType,
          "mimeType",
          "application/pdf",
        ),
      );
    });

    test('does not visualize text, which is not in UTF-8', () {
      final text = utf8.encode("Príliš žluťoučký kôň");

      expect(
        createDocumentPreview(
          _visualization("text/plain; charset=windows-1250;base64", text),
        ),
        isA<UnsupportedDocumentPreview>(),
      );
      expect(
        createDocumentPreview(
          _visualization("text/plain;base64", [0x50, 0xF8, 0xED, 0x6C]),
        ),
        isA<UnsupportedDocumentPreview>(),
      );
      expect(
        createDocumentPreview(
          _visualization("text/plain; charset=\"utf-8\";base64", text),
        ),
        isA<TextDocumentPreview>(),
      );
    });

    test('does not visualize document of other type', () {
      for (final mimeType in [
        "application/xml;base64",
        "text/html;base64",
        "application/msword;base64",
      ]) {
        expect(
          createDocumentPreview(_visualization(mimeType, utf8.encode("<a/>"))),
          isA<UnsupportedDocumentPreview>(),
          reason: mimeType,
        );
      }
    });
  });

  group('CreateDocumentPreviewUseCase.createServerVisualizationPreview', () {
    const createServerVisualizationPreview =
        CreateDocumentPreviewUseCase.createServerVisualizationPreview;

    test('creates preview from server visualization', () {
      final html = createServerVisualizationPreview(
        DocumentVisualizationResponseBody(
          mimeType: "text/html;base64",
          content: base64.encode(utf8.encode("<h1>Všeobecná agenda</h1>")),
        ),
      );
      final text = createServerVisualizationPreview(
        const DocumentVisualizationResponseBody(
          mimeType: "text/plain; charset=UTF-8",
          content: "Všeobecná agenda",
        ),
      );
      final unsupported = createServerVisualizationPreview(
        const DocumentVisualizationResponseBody(
          mimeType: "image/svg+xml;base64",
          content: "",
        ),
      );

      expect(
        html,
        isA<HtmlDocumentPreview>().having(
          (preview) => preview.html,
          "html",
          "<h1>Všeobecná agenda</h1>",
        ),
      );
      expect(
        text,
        isA<TextDocumentPreview>().having(
          (preview) => preview.text,
          "text",
          "Všeobecná agenda",
        ),
      );
      expect(
        unsupported,
        isA<UnsupportedDocumentPreview>().having(
          (preview) => preview.mimeType,
          "mimeType",
          "image/svg+xml;base64",
        ),
      );
    });
  });
}

VerifiableVisualizationResponseBody _loadVisualization(String name) {
  final json = jsonDecode(File("$_fixtures/$name.json").readAsStringSync());

  return VerifiableVisualizationResponseBody.fromJson(json["visualization"]);
}

VerifiableVisualizationResponseBody _visualization(
  String mimeType,
  List<int> content,
) {
  return VerifiableVisualizationResponseBody(
    signatureForm: VerifiableVisualizationResponseBodySignatureForm.xades,
    document: SignedDataObject(
      filename: "document",
      mimeType: mimeType,
      content: base64.encode(content),
    ),
  );
}
