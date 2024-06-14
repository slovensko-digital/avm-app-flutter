import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../data/signature_type.dart';
import '../use_case/get_document_signature_type_use_case.dart';
import 'get_document_signature_type_state.dart';

export 'get_document_signature_type_state.dart';

/// Cubit to get the Document [SignatureType].
@injectable
class GetDocumentSignatureTypeCubit
    extends Cubit<GetDocumentSignatureTypeState> {
  static final _log = Logger((GetDocumentSignatureTypeCubit).toString());

  final GetDocumentSignatureTypeUseCase _getDocumentSignatureType;

  GetDocumentSignatureTypeCubit({
    required GetDocumentSignatureTypeUseCase getDocumentSignatureType,
  })  : _getDocumentSignatureType = getDocumentSignatureType,
        super(const GetDocumentSignatureTypeInitialState());

  /// Sets the [signatureType] directly.
  void setSignatureType(SignatureType? signatureType) {
    emit(GetDocumentSignatureTypeSuccessState(signatureType));
  }

  /// Gets the Document [SignatureType].
  Future<void> getDocumentSignatureType(String documentId) async {
    emit(const GetDocumentSignatureTypeLoadingState());

    try {
      final signatureType = await _getDocumentSignatureType(documentId);

      _log.info("Got Document SignatureType: ${signatureType?.name}.");

      emit(GetDocumentSignatureTypeSuccessState(signatureType));
    } catch (error, stackTrace) {
      _log.severe("Error getting Document SignatureType.", error, stackTrace);

      emit(GetDocumentSignatureTypeErrorState(error));
    }
  }
}
