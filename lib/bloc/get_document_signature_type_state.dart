import 'package:flutter/foundation.dart' show immutable;

import '../data/signature_type.dart';
import 'get_document_signature_type_cubit.dart';

/// State for [GetDocumentSignatureTypeCubit].
@immutable
sealed class GetDocumentSignatureTypeState {
  const GetDocumentSignatureTypeState();

  @override
  String toString() => "$runtimeType()";
}

class GetDocumentSignatureTypeInitialState
    extends GetDocumentSignatureTypeState {
  const GetDocumentSignatureTypeInitialState();
}

class GetDocumentSignatureTypeLoadingState
    extends GetDocumentSignatureTypeState {
  const GetDocumentSignatureTypeLoadingState();
}

class GetDocumentSignatureTypeErrorState extends GetDocumentSignatureTypeState {
  final Object error;

  const GetDocumentSignatureTypeErrorState(this.error);

  @override
  String toString() => "$runtimeType(error: $error)";
}

class GetDocumentSignatureTypeSuccessState
    extends GetDocumentSignatureTypeState {
  final SignatureType? signatureType;

  const GetDocumentSignatureTypeSuccessState(this.signatureType);

  @override
  String toString() => "$runtimeType(signatureType: $signatureType)";
}
