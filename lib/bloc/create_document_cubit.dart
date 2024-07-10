import 'dart:async';
import 'dart:convert' show base64Encode;
import 'dart:io' show File;

import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../data/pdf_signing_option.dart';
import '../file_extensions.dart';
import '../files.dart';
import '../ui/screens/open_document_screen.dart';
import 'create_document_state.dart';
import 'preview_document_cubit.dart';

export 'create_document_state.dart';

/// Cubit for the [OpenDocumentScreen] with only [createDocument] function.
///
/// See also:
///  - [PreviewDocumentCubit]
@injectable
class CreateDocumentCubit extends Cubit<CreateDocumentState> {
  static final _log = Logger((CreateDocumentCubit).toString());

  final IAutogramService _service;
  final FutureOr<File> _file;
  final PdfSigningOption _pdfSigningOption;

  CreateDocumentCubit({
    required IAutogramService service,
    @factoryParam required FutureOr<File> file,
    @factoryParam required PdfSigningOption pdfSigningOption,
  })  : _service = service,
        _file = file,
        _pdfSigningOption = pdfSigningOption,
        super(const CreateDocumentInitialState());

  Future<void> createDocument() async {
    emit(state.toLoading());

    try {
      final file = await _file;

      // TODO Make intermediate states, when file is File and then content is loaded

      final payloadMimeType = getPayloadMimeType(file);
      final fileContent = await file.readAsBytes();

      // Create request body
      final signingParameters = getSigningParameters(file);
      final body = DocumentPostRequestBody(
        document: Document(
          filename: file.basename,
          // It has to be always base64 encoded even if it's text/xxx
          content: base64Encode(fileContent),
        ),
        parameters: signingParameters,
        payloadMimeType: payloadMimeType,
      );
      final documentId = await _service.createDocument(body);

      _log.info("New Document created: '$documentId'.");

      emit(state.toSuccess(file, documentId));
    } catch (error, stackTrace) {
      _log.severe("Error creating Document.", error, stackTrace);

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
  static String? getPayloadMimeType(File file) {
    final mimeType = Files.getFileMimeType(file);

    return (mimeType != null ? "$mimeType;base64" : null);
  }
}
