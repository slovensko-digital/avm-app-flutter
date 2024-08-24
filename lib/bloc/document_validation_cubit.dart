import 'dart:async';

import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../ui/fragment/document_validation_fragment.dart';
import 'document_validation_state.dart';

export 'document_validation_state.dart';

/// Cubit for the [DocumentValidationFragment] with only [createDocument] function.
///
/// See also:
///  - [PreviewDocumentCubit]
@injectable
class DocumentValidationCubit extends Cubit<DocumentValidationState> {
  static final _log = Logger((DocumentValidationCubit).toString());

  final IAutogramService _service;

  DocumentValidationCubit({
    required IAutogramService service,
  })  : _service = service,
        super(const DocumentValidationInitialState());

  Future<void> validateDocument(String documentId) async {
    _log.info("Requesting to validate Document Id: '$documentId'.");
    emit(const DocumentValidationLoadingState());

    try {
      final response = await _service.getDocumentValidation(documentId);

      _log.info("Got Document validation: $response.");

      emit(DocumentValidationSuccessState(response));
    } catch (error, stackTrace) {
      _log.severe("Error validating Document.", error, stackTrace);

      emit(DocumentValidationErrorState(error));
    }
  }
}
