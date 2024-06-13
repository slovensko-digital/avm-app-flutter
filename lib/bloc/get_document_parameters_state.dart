import 'package:flutter/foundation.dart';

import '../data/signature_type.dart';
import 'get_document_parameters_cubit.dart';

/// State for [GetDocumentParametersCubit].
@immutable
sealed class GetDocumentParametersState {
  const GetDocumentParametersState();

  @override
  String toString() => "$runtimeType()";
}

class GetDocumentParametersInitialState extends GetDocumentParametersState {
  const GetDocumentParametersInitialState();
}

class GetDocumentParametersLoadingState extends GetDocumentParametersState {
  const GetDocumentParametersLoadingState();
}

class GetDocumentParametersErrorState extends GetDocumentParametersState {
  final Object error;

  const GetDocumentParametersErrorState(this.error);

  @override
  String toString() => "$runtimeType(error: $error)";
}

class GetDocumentParametersSuccessState extends GetDocumentParametersState {
  final SignatureType? signatureType;

  const GetDocumentParametersSuccessState(this.signatureType);

  @override
  String toString() => "$runtimeType(signatureType: $signatureType)";
}
