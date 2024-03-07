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
  static final _log = Logger("PreviewDocumentCubit");

  final String documentId;
  final IAutogramService _service;

  PreviewDocumentCubit({
    required IAutogramService service,
    @factoryParam required this.documentId,
  })  : _service = service,
        super(const PreviewDocumentInitialState());

  Future<void> getVisualization() async {
    emit(state.toLoading());

    try {
      final visualization = await _service.getDocumentVisualization(documentId);

      emit(state.toSuccess(visualization));

      _log.info("Got Document Visualisation: ${visualization.runtimeType}.");
    } catch (error) {
      emit(state.toError(error));
    }
  }
}
