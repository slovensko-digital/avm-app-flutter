import 'dart:convert' show base64, jsonDecode, utf8;
import 'dart:io' show File;

import 'package:autogram/data/document_preview.dart';
import 'package:autogram/use_case/create_document_preview_use_case.dart';
import 'package:autogram/verification/document_verification_exception.dart';
import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixtures created by AVM server, see the `document_verification_test.dart`.
const _fixtures = "test/verification/fixtures";

/// Tests for the [CreateDocumentPreviewUseCase] class.
void main() {
  group('CreateDocumentPreviewUseCase', () {
    const createDocumentPreview =
        CreateDocumentPreviewUseCase.createDocumentPreview;

    test('transforms XML Datacontainer by verified referenced XSLT', () {
      final preview = createDocumentPreview(_loadVisualization("xades_xdc"));

      expect(
        preview,
        isA<TextDocumentPreview>().having(
          (preview) => preview.text,
          "text",
          "Všeobecná agenda\n"
              "\tPredmet: Testovacie podanie\n"
              "\tText: Podávam túto testovaciu všeobecnú žiadosť.",
        ),
      );
    });

    test('fails when referenced XSLT differs from its digest', () {
      final visualization = _loadVisualization("xades_xdc");
      final transformation = visualization.transformation!;
      final xslt = utf8.decode(base64.decode(transformation.content));
      final changed = visualization.copyWith(
        transformation: transformation.copyWith(
          content: base64.encode(
            utf8.encode(xslt.replaceFirst("Predmet: ", "Vec: ")),
          ),
        ),
      );

      expect(
        () => createDocumentPreview(changed),
        throwsA(
          isA<DocumentVerificationException>().having(
            (e) => e.reason,
            "reason",
            DocumentVerificationFailure.transformationMismatch,
          ),
        ),
      );
    });

    test('visualizes e-form data when referenced XSLT is missing', () {
      final visualization = _loadVisualization("xades_xdc").copyWithWrapped(
        transformation: const Wrapped.value(null),
      );

      final preview = createDocumentPreview(visualization);

      expect(
        preview,
        isA<TextDocumentPreview>().having(
          (preview) => preview.text,
          "text",
          allOf(
            startsWith("<GeneralAgenda"),
            contains("<subject>Testovacie podanie</subject>"),
          ),
        ),
      );
    });

    test('transforms XML Datacontainer by embedded XSLT to HTML', () {
      final preview = createDocumentPreview(
        _xmlDataContainer(
          '<xsl:output method="html"/>'
          '<xsl:template match="/">'
          '<html><body><h1><xsl:value-of select="t:Form/t:subject"/></h1>'
          '</body></html>'
          '</xsl:template>',
        ),
      );

      expect(
        preview,
        isA<HtmlDocumentPreview>().having(
          (preview) => preview.html,
          "html",
          contains("<h1>Predmet formulára</h1>"),
        ),
      );
    });

    test('visualizes e-form data when XSLT is not supported', () {
      final preview = createDocumentPreview(
        _xmlDataContainer(
          '<xsl:template match="/">'
          '<xsl:value-of select="document(\'form.xml\')"/>'
          '</xsl:template>',
        ),
      );

      expect(
        preview,
        isA<TextDocumentPreview>().having(
          (preview) => preview.text,
          "text",
          contains("<subject>Predmet formulára</subject>"),
        ),
      );
    });

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

    test('does not visualize document of unsupported type', () {
      final visualization = _loadVisualization("xades_txt");
      final preview = createDocumentPreview(
        visualization.copyWith(
          document: visualization.document.copyWith(
            mimeType: "application/msword;base64",
          ),
        ),
      );

      expect(preview, isA<UnsupportedDocumentPreview>());
    });
  });
}

VerifiableVisualizationResponseBody _loadVisualization(String name) {
  final json = jsonDecode(File("$_fixtures/$name.json").readAsStringSync());

  return VerifiableVisualizationResponseBody.fromJson(json["visualization"]);
}

/// Creates XAdES visualization of XML Datacontainer with embedded XSLT with
/// given [templates].
VerifiableVisualizationResponseBody _xmlDataContainer(String templates) {
  final xml =
      '''<?xml version="1.0" encoding="UTF-8"?>
<xdc:XMLDataContainer xmlns:xdc="http://data.gov.sk/def/container/xmldatacontainer+xml/1.1">
  <xdc:XMLData ContentType="application/xml; charset=UTF-8" Identifier="http://data.gov.sk/doc/eform/Test/1.0" Version="1.0">
    <Form xmlns="urn:test"><subject>Predmet formulára</subject></Form>
  </xdc:XMLData>
  <xdc:UsedSchemasEmbedded>
    <xdc:UsedPresentationSchemaEmbedded ContentType="application/xslt+xml">
      <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:t="urn:test">$templates</xsl:stylesheet>
    </xdc:UsedPresentationSchemaEmbedded>
  </xdc:UsedSchemasEmbedded>
</xdc:XMLDataContainer>''';

  return VerifiableVisualizationResponseBody(
    signatureForm: VerifiableVisualizationResponseBodySignatureForm.xades,
    document: SignedDataObject(
      filename: "form.xdcf",
      mimeType: "application/vnd.gov.sk.xmldatacontainer+xml;base64",
      content: base64.encode(utf8.encode(xml)),
    ),
  );
}
