import 'dart:io' show File;

import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../ui/screens/preview_document_screen.dart';
import '../use_case/create_document_preview_use_case.dart';
import '../verification/local_document_verifier.dart';
import 'create_document_cubit.dart';
import 'preview_document_state.dart';

export 'preview_document_state.dart';

/// Cubit for the [PreviewDocumentScreen] with only [getVisualization] function.
///
/// The document is visualized on the device from the data objects covered by
/// the signature and it's verified against the selected [file].
///
/// See also:
///  - [CreateDocumentCubit]
@injectable
class PreviewDocumentCubit extends Cubit<PreviewDocumentState> {
  static final _log = Logger((PreviewDocumentCubit).toString());

  final IAutogramService _service;
  final CreateDocumentPreviewUseCase _createDocumentPreview;
  final String documentId;

  /// Local document selected by the user, `null` for remote document.
  final File? file;

  PreviewDocumentCubit({
    required IAutogramService service,
    required CreateDocumentPreviewUseCase createDocumentPreview,
    @factoryParam required this.documentId,
    @factoryParam this.file,
  })  : _service = service,
        _createDocumentPreview = createDocumentPreview,
        super(const PreviewDocumentInitialState());

  /// Gets the Document Visualisation for [documentId].
  Future<void> getVisualization() async {
    emit(state.toLoading());

    try {
      _log.info("Getting Document Visualisation for Document Id: $documentId");

      final visualization =
          await _service.getDocumentVerifiableVisualization(documentId);

      final file = this.file;
      if (file != null) {
        LocalDocumentVerifier.verify(visualization, await file.readAsBytes());
      }

      final preview = await _createDocumentPreview(visualization);

      _log.info("Got Document Visualisation.");

      emit(state.toSuccess(visualization, preview));
    } catch (error, stackTrace) {
      _log.severe("Error getting Document Visualisation.", error, stackTrace);

      emit(state.toError(error));
    }
  }
}
