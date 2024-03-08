import 'package:autogram_sign/autogram_sign.dart';
import 'package:eidmsdk/eidmsdk.dart';
import 'package:eidmsdk/types.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../ui/screens/sign_document_screen.dart';
import 'sign_document_state.dart';

export 'sign_document_state.dart';

/// Cubit for the [SignDocumentScreen].
@injectable
class SignDocumentCubit extends Cubit<SignDocumentState> {
  static final _log = Logger("SignDocumentCubit");
  static const _defaultLanguage = 'sk';

  final IAutogramService _service;
  final Eidmsdk _eidmsdk;

  final String documentId;
  final Certificate certificate;

  SignDocumentCubit({
    required IAutogramService service,
    required Eidmsdk eidmsdk,
    @factoryParam required this.documentId,
    @factoryParam required this.certificate,
  })  : _service = service,
        _eidmsdk = eidmsdk,
        super(const SignDocumentInitialState());

  /// Signs the document using given [certificate].
  Future<void> signDocument(bool addTimestamp) async {
    DataToSignStructure data;

    try {
      emit(state.toLoading());

      final dataToSignRequest = DocumentsGuidDatatosignPost$RequestBody(
        signingCertificate: certificate.certData,
        addTimestamp: addTimestamp,
      );

      data = await _service.setDataToSign(documentId, dataToSignRequest);

      _log.info("Got data to sign from backend.");
    } catch (error) {
      emit(state.toError(error));
      return;
    }

    String? signResult;

    try {
      emit(state.toLoading());

      signResult = await _eidmsdk.signData(
        certIndex: certificate.certIndex,
        signatureScheme: '1.2.840.113549.1.1.11',
        dataToSign: data.dataToSign,
        isBase64Encoded: true,
        language: _defaultLanguage,
      );

      if (signResult == null) {
        emit(state.toCanceled());
        return;
      }

      // TODO Set state with signResult so we can retry next operation (need to check it on top)
    } catch (error) {
      emit(state.toError(error));
      return;
    }

    try {
      emit(state.toLoading());

      final signRequest = SignRequestBody(
        signedData: signResult,
        dataToSignStructure: DataToSignStructure(
          dataToSign: data.dataToSign,
          signingCertificate: certificate.certData,
          signingTime: data.signingTime,
        ),
      );
      final signedDocument = await _service.signDocument(
        documentId,
        signRequest,
        true,
      );

      emit(state.toSuccess(signedDocument));

      _log.info("Document was successfully signed.");
    } catch (error) {
      emit(state.toError(error));
      return;
    }
  }
}
