import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../data/signature_type.dart';
import 'get_document_parameters_state.dart';

export 'get_document_parameters_state.dart';

/// Cubit to get the Document [SigningParameters].
@injectable
class GetDocumentParametersCubit extends Cubit<GetDocumentParametersState> {
  static final _log = Logger((GetDocumentParametersCubit).toString());

  final IAutogramService _autogramService;

  GetDocumentParametersCubit({
    required IAutogramService autogramService,
  })  : _autogramService = autogramService,
        super(const GetDocumentParametersInitialState());

  /// Loads the Document parameters needed to preset [SignatureType].
  Future<void> loadDocumentParameters(String documentId) async {
    emit(const GetDocumentParametersLoadingState());

    try {
      final params = await _autogramService.getDocumentParameters(documentId);
      final SignatureType? signatureType = switch (params.level) {
        null => null,
        SigningParametersLevel.cadesBaselineT => SignatureType.withTimestamp,
        SigningParametersLevel.padesBaselineT => SignatureType.withTimestamp,
        SigningParametersLevel.xadesBaselineT => SignatureType.withTimestamp,
        _ => SignatureType.withoutTimestamp
      };

      _log.info(
          "Got Document Parameters; Signature Type is: ${signatureType?.name}.");

      emit(GetDocumentParametersSuccessState(signatureType));
    } catch (error, stackTrace) {
      _log.severe("Error getting Document Parameters.", error, stackTrace);

      emit(GetDocumentParametersErrorState(error));
    }
  }
}
