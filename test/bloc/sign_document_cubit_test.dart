import 'dart:convert' show base64, jsonDecode, utf8;
import 'dart:io' show File;

import 'package:autogram/bloc/sign_document_cubit.dart';
import 'package:autogram/data/document_to_sign.dart';
import 'package:autogram/data/signature_type.dart';
import 'package:autogram/verification/document_verification_exception.dart';
import 'package:autogram_sign/autogram_sign.dart';
import 'package:eidmsdk/eidmsdk.dart';
import 'package:eidmsdk/types.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixtures created by AVM server, see the `document_verification_test.dart`.
const _fixtures = "test/verification/fixtures";

const _certificate = Certificate(
  slot: "1",
  supportedSchemes: [],
  isQualified: true,
  certIndex: 1,
  certData: "certificate",
);

/// Tests for the [SignDocumentCubit].
void main() {
  group('SignDocumentCubit', () {
    test('signs data to sign of the visualized document', () async {
      final fixture = _loadFixture("pades_pdf");
      final service = _Service(fixture.dataToSign);
      final eidmsdk = _Eidmsdk();
      final cubit = SignDocumentCubit(
        service: service,
        eidmsdk: eidmsdk,
        document: DocumentToSign(id: "1", visualization: fixture.visualization),
        certificate: _certificate,
      );

      await cubit.signDocument(SignatureType.withoutTimestamp);

      expect(cubit.state, isA<SignDocumentSuccessState>());
      expect(
        service.dataToSignRequest?.signingTime,
        fixture.visualization.signingTime,
      );
      expect(eidmsdk.signedData, [fixture.dataToSign.dataToSign]);
    });

    test('does not sign data to sign of other document', () async {
      final fixture = _loadFixture("xades_txt");
      final visualization = fixture.visualization.copyWith(
        document: fixture.visualization.document.copyWith(
          content: base64.encode(utf8.encode("Iný obsah dokumentu")),
        ),
      );
      final eidmsdk = _Eidmsdk();
      final cubit = SignDocumentCubit(
        service: _Service(fixture.dataToSign),
        eidmsdk: eidmsdk,
        document: DocumentToSign(id: "1", visualization: visualization),
        certificate: _certificate,
      );

      await cubit.signDocument(SignatureType.withoutTimestamp);

      expect(
        cubit.state,
        isA<SignDocumentErrorState>().having(
          (state) => state.error,
          "error",
          isA<DocumentVerificationException>().having(
            (e) => e.reason,
            "reason",
            DocumentVerificationFailure.dataToSignMismatch,
          ),
        ),
      );
      expect(eidmsdk.signedData, isEmpty);
    });
  });
}

({
  VerifiableVisualizationResponseBody visualization,
  DataToSignStructure dataToSign,
})
_loadFixture(String name) {
  final json = jsonDecode(File("$_fixtures/$name.json").readAsStringSync());

  return (
    visualization: VerifiableVisualizationResponseBody.fromJson(
      json["visualization"],
    ),
    dataToSign: DataToSignStructure.fromJson(json["dataToSign"]),
  );
}

class _Service extends Fake implements IAutogramService {
  final DataToSignStructure dataToSign;
  DataToSignRequestBody? dataToSignRequest;

  _Service(this.dataToSign);

  @override
  Future<DataToSignStructure> setDataToSign(
    String documentId,
    DataToSignRequestBody body,
  ) async {
    dataToSignRequest = body;

    return dataToSign;
  }

  @override
  Future<SignDocumentResponseBody> signDocument(
    String documentId,
    SignRequestBody body, [
    bool returnSignedDocument = true,
  ]) async {
    return const SignDocumentResponseBody(
      filename: "signed.pdf",
      mimeType: SignDocumentResponseBodyMimeType.applicationPdfBase64,
      content: "",
      signedBy: "",
      issuedBy: "",
    );
  }
}

class _Eidmsdk extends Fake implements Eidmsdk {
  final signedData = <String>[];

  @override
  Future<String?> signData({
    required int certIndex,
    required String signatureScheme,
    required String dataToSign,
    bool isBase64Encoded = false,
    String? language,
  }) async {
    signedData.add(dataToSign);

    return "signature";
  }
}
