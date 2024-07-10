import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../ui/screens/preview_document_screen.dart';
import 'create_document_cubit.dart';
import 'preview_document_state.dart';

export 'preview_document_state.dart';

/// Cubit for the [PreviewDocumentScreen] with only [getVisualization] function.
///
/// See also:
///  - [CreateDocumentCubit]
@injectable
class PreviewDocumentCubit extends Cubit<PreviewDocumentState> {
  static final _log = Logger((PreviewDocumentCubit).toString());

  final IAutogramService _service;
  final String documentId;

  PreviewDocumentCubit({
    required IAutogramService service,
    @factoryParam required this.documentId,
  })  : _service = service,
        super(const PreviewDocumentInitialState());

  /// Gets the Document Visualisation for [documentId].
  Future<void> getVisualization() async {
    emit(state.toLoading());

    try {
      _log.info("Getting Document Visualisation for DocumentId: $documentId");

      final visualization = await _service.getDocumentVisualization(documentId);

      _log.info("Got Document Visualisation.");

      emit(state.toSuccess(visualization));
    } catch (error, stackTrace) {
      _log.severe("Error getting Document Visualisation.", error, stackTrace);

      emit(state.toError(error));
    }
  }
}
