import 'dart:convert' show base64, jsonDecode, utf8;
import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;

import 'package:autogram/verification/cms_signed_attributes.dart';
import 'package:autogram/verification/data_to_sign_verifier.dart';
import 'package:autogram/verification/document_verification_exception.dart';
import 'package:autogram/verification/local_document_verifier.dart';
import 'package:autogram/verification/xml_data_container.dart';
import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixtures were created by AVM server with AVM service (DSS):
/// `GET /verifiable-visualization` -> `POST /datatosign` -> `POST /sign`
/// and the signature was successfully created.
typedef _Fixture = ({
  VerifiableVisualizationResponseBody visualization,
  DataToSignStructure dataToSign,
});

const _fixtures = "test/verification/fixtures";

/// Fixture name -> local document from which the document was created.
const _localDocuments = {
  "xades_txt": "doc.txt",
  "cades_txt": "doc.txt",
  "cades_p7m": "doc.txt",
  "pades_pdf": "sample.pdf",
  "pades_pdf_timestamp": "sample.pdf",
  "xades_xdc": "general_agenda.xml",
  "xades_asice": "doc_signed.asice",
  "pades_signed_pdf": "sample_signed.pdf",
};

void main() {
  group('DataToSignVerifier', () {
    for (final name in _localDocuments.keys) {
      test('verifies data to sign of $name', () {
        final fixture = _loadFixture(name);

        DataToSignVerifier.verify(
          fixture.visualization,
          fixture.dataToSign.dataToSign,
        );
      });
    }

    test('PAdES data to sign verifies after changing signature level', () {
      // visualization was created for B level, data to sign for T level
      final fixture = _loadFixture("pades_pdf_timestamp");

      expect(fixture.visualization.signingTime, fixture.dataToSign.signingTime);
      DataToSignVerifier.verify(
        fixture.visualization,
        fixture.dataToSign.dataToSign,
      );
    });

    test('fails when XAdES document content differs', () {
      final fixture = _loadFixture("xades_txt");
      final visualization = _withDocument(
        fixture.visualization,
        content: utf8.encode("Iný obsah dokumentu"),
      );

      _expectFailure(
        () => DataToSignVerifier.verify(
          visualization,
          fixture.dataToSign.dataToSign,
        ),
        DocumentVerificationFailure.dataToSignMismatch,
      );
    });

    test('fails when XAdES document filename differs', () {
      final fixture = _loadFixture("xades_txt");
      final visualization = _withDocument(
        fixture.visualization,
        filename: "other.txt",
      );

      _expectFailure(
        () => DataToSignVerifier.verify(
          visualization,
          fixture.dataToSign.dataToSign,
        ),
        DocumentVerificationFailure.dataToSignMismatch,
      );
    });

    test('fails when data to sign is of other document', () {
      final fixture = _loadFixture("xades_txt");
      final other = _loadFixture("xades_xdc");

      _expectFailure(
        () => DataToSignVerifier.verify(
          fixture.visualization,
          other.dataToSign.dataToSign,
        ),
        DocumentVerificationFailure.dataToSignMismatch,
      );
    });

    test('fails when SignedInfo references another data object', () {
      final fixture = _loadFixture("xades_txt");
      final signedInfo = utf8.decode(
        base64.decode(fixture.dataToSign.dataToSign),
      );
      final reference = RegExp(
        r'<ds:Reference Id="[^"]*" URI="doc.txt">.*?</ds:Reference>',
      ).firstMatch(signedInfo)!.group(0)!;
      final tampered = signedInfo.replaceFirst(
        reference,
        reference + reference.replaceAll("doc.txt", "hidden.txt"),
      );

      _expectFailure(
        () => DataToSignVerifier.verify(
          fixture.visualization,
          base64.encode(utf8.encode(tampered)),
        ),
        DocumentVerificationFailure.unsupportedData,
      );
    });

    test('fails when SignedInfo uses weak digest algorithm', () {
      final fixture = _loadFixture("xades_txt");
      final signedInfo = utf8.decode(
        base64.decode(fixture.dataToSign.dataToSign),
      );
      final tampered = signedInfo.replaceFirst(
        "http://www.w3.org/2001/04/xmlenc#sha256",
        "http://www.w3.org/2000/09/xmldsig#sha1",
      );

      _expectFailure(
        () => DataToSignVerifier.verify(
          fixture.visualization,
          base64.encode(utf8.encode(tampered)),
        ),
        DocumentVerificationFailure.unsupportedData,
      );
    });

    test('fails when data object in SignedInfo is transformed', () {
      final fixture = _loadFixture("xades_txt");
      final signedInfo = utf8.decode(
        base64.decode(fixture.dataToSign.dataToSign),
      );
      final tampered = signedInfo.replaceFirst(
        RegExp(r'(URI="doc.txt">)'),
        r'URI="doc.txt"><ds:Transforms><ds:Transform Algorithm="http://www.w3.org/TR/1999/REC-xpath-19991116"></ds:Transform></ds:Transforms>',
      );

      _expectFailure(
        () => DataToSignVerifier.verify(
          fixture.visualization,
          base64.encode(utf8.encode(tampered)),
        ),
        DocumentVerificationFailure.unsupportedData,
      );
    });

    test('fails when CAdES document differs from ASiC manifest', () {
      final fixture = _loadFixture("cades_txt");
      final visualization = _withDocument(
        fixture.visualization,
        content: utf8.encode("Iný obsah dokumentu"),
      );

      _expectFailure(
        () => DataToSignVerifier.verify(
          visualization,
          fixture.dataToSign.dataToSign,
        ),
        DocumentVerificationFailure.dataToSignMismatch,
      );
    });

    test('fails when ASiC manifest differs from data to sign', () {
      final fixture = _loadFixture("cades_txt");
      final manifest = fixture.visualization.asicManifest!;
      final tampered = utf8.decode(base64.decode(manifest.content)).replaceFirst(
        "<asic:SigReference",
        "<!-- --><asic:SigReference",
      );
      final visualization = fixture.visualization.copyWith(
        asicManifest: manifest.copyWith(
          content: base64.encode(utf8.encode(tampered)),
        ),
      );

      _expectFailure(
        () => DataToSignVerifier.verify(
          visualization,
          fixture.dataToSign.dataToSign,
        ),
        DocumentVerificationFailure.dataToSignMismatch,
      );
    });

    test('fails when CAdES without container signs other document', () {
      final fixture = _loadFixture("cades_p7m");
      final visualization = _withDocument(
        fixture.visualization,
        content: utf8.encode("Iný obsah dokumentu"),
      );

      _expectFailure(
        () => DataToSignVerifier.verify(
          visualization,
          fixture.dataToSign.dataToSign,
        ),
        DocumentVerificationFailure.dataToSignMismatch,
      );
    });

    test('fails when PDF differs in covered bytes', () {
      final fixture = _loadFixture("pades_pdf");
      final pdf = base64.decode(fixture.visualization.document.content);
      // change the first byte after "%PDF-1."
      pdf[7] = pdf[7] == 0x34 ? 0x35 : 0x34;
      final visualization = _withDocument(fixture.visualization, content: pdf);

      _expectFailure(
        () => DataToSignVerifier.verify(
          visualization,
          fixture.dataToSign.dataToSign,
        ),
        DocumentVerificationFailure.dataToSignMismatch,
      );
    });

    test('fails when PDF was prepared with other signing time', () {
      final fixture = _loadFixture("pades_pdf");
      final other = _loadFixture("pades_pdf_timestamp");

      _expectFailure(
        () => DataToSignVerifier.verify(
          fixture.visualization,
          other.dataToSign.dataToSign,
        ),
        DocumentVerificationFailure.dataToSignMismatch,
      );
    });

    test('fails when PDF byte range does not cover whole document', () {
      final fixture = _loadFixture("pades_pdf");
      final [offset1, length1, offset2, length2] =
          fixture.visualization.pdfByteRange!;

      for (final byteRange in [
        [offset1, length1 - 10, offset2, length2],
        [offset1, length1, offset2 + 10, length2 - 10],
        [offset1, length1, offset2, length2 - 1],
        [offset1, length1, offset2],
      ]) {
        _expectFailure(
          () => DataToSignVerifier.verify(
            fixture.visualization.copyWith(pdfByteRange: byteRange),
            fixture.dataToSign.dataToSign,
          ),
          DocumentVerificationFailure.unsupportedData,
        );
      }
    });

    test('fails when PDF signature contents is not empty', () {
      final fixture = _loadFixture("pades_pdf");
      final pdf = base64.decode(fixture.visualization.document.content);
      final length1 = fixture.visualization.pdfByteRange![1];
      pdf[length1 + 1] = 0x31;
      final visualization = _withDocument(fixture.visualization, content: pdf);

      _expectFailure(
        () => DataToSignVerifier.verify(
          visualization,
          fixture.dataToSign.dataToSign,
        ),
        DocumentVerificationFailure.unsupportedData,
      );
    });

    test('fails when data to sign is not base64', () {
      final fixture = _loadFixture("xades_txt");

      _expectFailure(
        () => DataToSignVerifier.verify(fixture.visualization, "%%%"),
        DocumentVerificationFailure.unsupportedData,
      );
    });
  });

  group('CmsSignedAttributes', () {
    test('parses message digest', () {
      final fixture = _loadFixture("cades_p7m");
      final document = base64.decode(fixture.visualization.document.content);
      final attributes = CmsSignedAttributes.parse(
        base64.decode(fixture.dataToSign.dataToSign),
      );

      expect(attributes.messageDigest.length, 32);
      expect(document, isNotEmpty);
    });

    test('refuses trailing data', () {
      final fixture = _loadFixture("cades_p7m");
      final data = base64.decode(fixture.dataToSign.dataToSign);

      _expectFailure(
        () => CmsSignedAttributes.parse(Uint8List.fromList([...data, 0])),
        DocumentVerificationFailure.unsupportedData,
      );
    });

    test('refuses duplicate message digest', () {
      final messageDigest = [
        0x30, 0x2F, //
        0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x09, 0x04,
        0x31, 0x22, 0x04, 0x20, ...List.filled(32, 0x11),
      ];
      final attributes = [...messageDigest, ...messageDigest];

      _expectFailure(
        () => CmsSignedAttributes.parse(
          Uint8List.fromList([0x31, 0x62, ...attributes]),
        ),
        DocumentVerificationFailure.unsupportedData,
      );
      expect(
        CmsSignedAttributes.parse(
          Uint8List.fromList([0x31, 0x31, ...messageDigest]),
        ).messageDigest,
        List.filled(32, 0x11),
      );
    });

    test('refuses non-minimal length', () {
      _expectFailure(
        () => CmsSignedAttributes.parse(Uint8List.fromList([0x31, 0x81, 0x00])),
        DocumentVerificationFailure.unsupportedData,
      );
    });
  });

  group('LocalDocumentVerifier', () {
    for (final MapEntry(key: name, value: localDocument)
        in _localDocuments.entries) {
      test('verifies $name against local $localDocument', () {
        final fixture = _loadFixture(name);

        LocalDocumentVerifier.verify(
          fixture.visualization,
          _loadFile(localDocument),
        );
      });
    }

    test('fails when visualized document is not the local one', () {
      _expectFailure(
        () => LocalDocumentVerifier.verify(
          _loadFixture("xades_txt").visualization,
          utf8.encode("Iný dokument"),
        ),
        DocumentVerificationFailure.localDocumentMismatch,
      );
    });

    test('fails when prepared PDF is not update of the local PDF', () {
      final pdf = _loadFile("sample.pdf");
      pdf[pdf.length - 10] ^= 1;

      _expectFailure(
        () => LocalDocumentVerifier.verify(
          _loadFixture("pades_pdf").visualization,
          pdf,
        ),
        DocumentVerificationFailure.localDocumentMismatch,
      );
    });

    test('fails when XML Datacontainer contains other form data', () {
      final xml = utf8.decode(_loadFile("general_agenda.xml"));

      _expectFailure(
        () => LocalDocumentVerifier.verify(
          _loadFixture("xades_xdc").visualization,
          utf8.encode(xml.replaceFirst("Testovacie", "Iné")),
        ),
        DocumentVerificationFailure.localDocumentMismatch,
      );
    });

    test('fails when ASiC container does not contain visualized document', () {
      final visualization = _withDocument(
        _loadFixture("xades_asice").visualization,
        filename: "other.txt",
      );

      _expectFailure(
        () => LocalDocumentVerifier.verify(
          visualization,
          _loadFile("doc_signed.asice"),
        ),
        DocumentVerificationFailure.localDocumentMismatch,
      );
    });
  });

  group('XmlDataContainer', () {
    test('verifies referenced transformation', () {
      final visualization = _loadFixture("xades_xdc").visualization;
      final xdc = XmlDataContainer.parse(
        base64.decode(visualization.document.content),
      );

      expect(xdc.formData.name.local, "GeneralAgenda");
      expect(xdc.mediaDestinationTypeDescription, "TXT");
      expect(xdc.embeddedTransformation, isNull);
      xdc.verifyTransformation(
        base64.decode(visualization.transformation!.content),
      );
    });

    test('fails when transformation differs', () {
      final visualization = _loadFixture("xades_xdc").visualization;
      final xdc = XmlDataContainer.parse(
        base64.decode(visualization.document.content),
      );
      final transformation = utf8
          .decode(base64.decode(visualization.transformation!.content))
          .replaceFirst("Predmet: ", "Predmet:: ");

      _expectFailure(
        () => xdc.verifyTransformation(utf8.encode(transformation)),
        DocumentVerificationFailure.transformationMismatch,
      );
    });
  });
}

_Fixture _loadFixture(String name) {
  final json = jsonDecode(File("$_fixtures/$name.json").readAsStringSync());

  return (
    visualization: VerifiableVisualizationResponseBody.fromJson(
      json["visualization"],
    ),
    dataToSign: DataToSignStructure.fromJson(json["dataToSign"]),
  );
}

Uint8List _loadFile(String name) {
  return File("$_fixtures/$name").readAsBytesSync();
}

VerifiableVisualizationResponseBody _withDocument(
  VerifiableVisualizationResponseBody visualization, {
  List<int>? content,
  String? filename,
}) {
  return visualization.copyWith(
    document: visualization.document.copyWith(
      content: content == null ? null : base64.encode(content),
      filename: filename,
    ),
  );
}

void _expectFailure(
  void Function() verify,
  DocumentVerificationFailure reason,
) {
  expect(
    verify,
    throwsA(
      isA<DocumentVerificationException>().having(
        (e) => e.reason,
        "reason",
        reason,
      ),
    ),
  );
}
