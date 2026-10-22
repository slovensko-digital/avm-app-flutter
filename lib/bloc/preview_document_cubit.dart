import 'dart:io' show File;

import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../data/document_preview.dart';
import '../data/server_document.dart';
import '../services/autogram_services.dart';
import '../ui/screens/preview_document_screen.dart';
import '../use_case/create_document_preview_use_case.dart';
import '../verification/document_verification_exception.dart';
import '../verification/local_document_verifier.dart';
import 'create_document_cubit.dart';
import 'preview_document_state.dart';

export 'preview_document_state.dart';

/// Cubit for the [PreviewDocumentScreen] with only [getVisualization] function.
///
/// The document is visualized on the device from the data objects covered by
/// the signature and it's verified against the selected [file]. Documents,
/// which can't be visualized on the device, are visualized by the official
/// server; such documents can't be signed from other servers.
///
/// See also:
///  - [CreateDocumentCubit]
@injectable
class PreviewDocumentCubit extends Cubit<PreviewDocumentState> {
  static final _log = Logger((PreviewDocumentCubit).toString());

  final AutogramServices _services;
  final CreateDocumentPreviewUseCase _createDocumentPreview;
  final ServerDocument document;

  /// Local document selected by the user, `null` for remote document.
  final File? file;

  PreviewDocumentCubit({
    required AutogramServices services,
    required CreateDocumentPreviewUseCase createDocumentPreview,
    @factoryParam required this.document,
    @factoryParam this.file,
  })  : _services = services,
        _createDocumentPreview = createDocumentPreview,
        super(const PreviewDocumentInitialState());

  /// Gets the Document Visualisation for [document].
  Future<void> getVisualization() async {
    emit(state.toLoading());

    try {
      _log.info("Getting Document Visualisation for $document.");

      final service = _services.of(document.server);
      final visualization = await service.getDocumentVerifiableVisualization(
        document.id,
      );

      final file = this.file;
      if (file != null) {
        LocalDocumentVerifier.verify(visualization, await file.readAsBytes());
      }

      var preview = await _createDocumentPreview(visualization);

      if (preview is UnsupportedDocumentPreview) {
        // other servers can't be trusted to visualize the document
        if (!document.server.isOfficial) {
          throw DocumentVerificationException(
            DocumentVerificationFailure.unsupportedDocumentType,
            "Document of type ${preview.mimeType} from ${document.server} "
            "can't be visualized on the device.",
          );
        }

        // e.g. e-form transformed by its XSLT on the server
        preview = await _createDocumentPreview.fromServerVisualization(
          await service.getDocumentVisualization(document.id),
        );
      }

      _log.info("Got Document Visualisation.");

      emit(state.toSuccess(visualization, preview));
    } catch (error, stackTrace) {
      _log.severe("Error getting Document Visualisation.", error, stackTrace);

      emit(state.toError(error));
    }
  }
}
