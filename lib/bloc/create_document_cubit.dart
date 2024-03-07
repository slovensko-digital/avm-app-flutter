import 'dart:convert' show base64Encode;
import 'dart:io' show File;

import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../data/pdf_signing_option.dart';
import '../file_extensions.dart';
import '../ui/screens/open_document_screen.dart';
import '../utils.dart';
import 'create_document_state.dart';
import 'preview_document_cubit.dart';

export 'create_document_state.dart';

/// Cubit for the [OpenDocumentScreen] with only [createDocument] function.
///
/// See also:
///  - [PreviewDocumentCubit]
@injectable
class CreateDocumentCubit extends Cubit<CreateDocumentState> {
  static final _log = Logger("CreateDocumentCubit");

  final IAutogramService _service;
  final PdfSigningOption _pdfSigningOption;

  CreateDocumentCubit({
    required IAutogramService service,
    @factoryParam required File file,
    @factoryParam required PdfSigningOption pdfSigningOption,
  })  : _service = service,
        _pdfSigningOption = pdfSigningOption,
        super(CreateDocumentInitialState(file));

  Future<void> createDocument() async {
    emit(state.toLoading());

    final file = state.file;

    try {
      final payloadMimeType = getPayloadMimeType(file);
      final fileContent = await file.readAsBytes();

      // Create request body
      final signingParameters = getSigningParameters(file);
      final body = DocumentPostRequestBody(
        document: Document(
          filename: file.basename,
          // TODO Test text/plain w/o base64Encode
          content: base64Encode(fileContent),
        ),
        parameters: signingParameters,
        payloadMimeType: payloadMimeType,
      );
      final documentId = await _service.createDocument(body);

      emit(state.toSuccess(documentId));

      _log.info("New Document created: '$documentId'.");
    } catch (error) {
      emit(state.toError(error));
    }
  }

  /// Gets the [SigningParameters] for [file].
  SigningParameters getSigningParameters(File file) {
    final extension = file.extension.replaceFirst('.', '').toLowerCase();

    return switch (extension) {
      "pdf" => SigningParameters(
          level: _pdfSigningOption.level,
          container: switch (_pdfSigningOption) {
            PdfSigningOption.pades => null,
            PdfSigningOption.xades => SigningParametersContainer.asicE,
            PdfSigningOption.cades => SigningParametersContainer.asicE,
          },
        ),
      _ => const SigningParameters(
          level: SigningParametersLevel.xadesBaselineB,
          container: SigningParametersContainer.asicE,
        ),
    };
  }

  /// Gets the payload Mime type for [file].
  static String getPayloadMimeType(File file) {
    return Utils.getFileMimeType(file);
  }
}
