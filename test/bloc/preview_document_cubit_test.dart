import 'dart:convert' show jsonDecode;
import 'dart:io' show File;

import 'package:autogram/bloc/preview_document_cubit.dart';
import 'package:autogram/data/avm_server.dart';
import 'package:autogram/data/document_preview.dart';
import 'package:autogram/data/server_document.dart';
import 'package:autogram/services/autogram_services.dart';
import 'package:autogram/use_case/create_document_preview_use_case.dart';
import 'package:autogram/verification/document_verification_exception.dart';
import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixtures created by AVM server, see the `document_verification_test.dart`.
const _fixtures = "test/verification/fixtures";

const _otherServer = AvmServer("avm.example.org");

/// Tests for the [PreviewDocumentCubit].
void main() {
  group('PreviewDocumentCubit', () {
    test('visualizes PDF from other server on the device', () async {
      final service = _Service(_loadVisualization("pades_pdf"));
      final cubit = _cubit(
        service,
        const ServerDocument("1", server: _otherServer),
      );

      await cubit.getVisualization();

      expect(
        cubit.state,
        isA<PreviewDocumentSuccessState>().having(
          (state) => state.preview,
          "preview",
          isA<PdfDocumentPreview>(),
        ),
      );
      expect(service.requestedDocumentIds, ["1"]);
      expect(service.serverVisualizationRequested, isFalse);
    });

    test('does not visualize e-form from other server', () async {
      final service = _Service(
        _loadVisualization("xades_xdc"),
        serverVisualization: const DocumentVisualizationResponseBody(
          mimeType: "text/plain",
          content: "Všeobecná agenda",
        ),
      );
      final cubit = _cubit(
        service,
        const ServerDocument("1", server: _otherServer),
      );

      await cubit.getVisualization();

      expect(
        cubit.state,
        isA<PreviewDocumentErrorState>().having(
          (state) => state.error,
          "error",
          isA<DocumentVerificationException>().having(
            (e) => e.reason,
            "reason",
            DocumentVerificationFailure.unsupportedDocumentType,
          ),
        ),
      );
      expect(service.serverVisualizationRequested, isFalse);
    });

    test('visualizes e-form from official server by the server', () async {
      final service = _Service(
        _loadVisualization("xades_xdc"),
        serverVisualization: const DocumentVisualizationResponseBody(
          mimeType: "text/plain",
          content: "Všeobecná agenda",
        ),
      );
      final cubit = _cubit(service, const ServerDocument("1"));

      await cubit.getVisualization();

      expect(
        cubit.state,
        isA<PreviewDocumentSuccessState>().having(
          (state) => state.preview,
          "preview",
          isA<TextDocumentPreview>().having(
            (preview) => preview.text,
            "text",
            "Všeobecná agenda",
          ),
        ),
      );
    });

    test('fails when document differs from the selected file', () async {
      final service = _Service(_loadVisualization("xades_txt"));
      final cubit = _cubit(
        service,
        const ServerDocument("1"),
        File("$_fixtures/sample.pdf"),
      );

      await cubit.getVisualization();

      expect(
        cubit.state,
        isA<PreviewDocumentErrorState>().having(
          (state) => state.error,
          "error",
          isA<DocumentVerificationException>().having(
            (e) => e.reason,
            "reason",
            DocumentVerificationFailure.localDocumentMismatch,
          ),
        ),
      );
    });
  });
}

PreviewDocumentCubit _cubit(
  _Service service,
  ServerDocument document, [
  File? file,
]) {
  return PreviewDocumentCubit(
    services: _Services(document.server, service),
    createDocumentPreview: CreateDocumentPreviewUseCase(),
    document: document,
    file: file,
  );
}

VerifiableVisualizationResponseBody _loadVisualization(String name) {
  final json = jsonDecode(File("$_fixtures/$name.json").readAsStringSync());

  return VerifiableVisualizationResponseBody.fromJson(json["visualization"]);
}

class _Services extends Fake implements AutogramServices {
  final AvmServer server;
  final IAutogramService service;

  _Services(this.server, this.service);

  @override
  IAutogramService of(AvmServer server) {
    expect(server, this.server);

    return service;
  }
}

class _Service extends Fake implements IAutogramService {
  final VerifiableVisualizationResponseBody visualization;
  final DocumentVisualizationResponseBody? serverVisualization;
  final requestedDocumentIds = <String>[];
  bool serverVisualizationRequested = false;

  _Service(this.visualization, {this.serverVisualization});

  @override
  Future<VerifiableVisualizationResponseBody>
  getDocumentVerifiableVisualization(String documentId) async {
    requestedDocumentIds.add(documentId);

    return visualization;
  }

  @override
  Future<DocumentVisualizationResponseBody> getDocumentVisualization(
    String documentId,
  ) async {
    serverVisualizationRequested = true;

    return serverVisualization!;
  }
}
