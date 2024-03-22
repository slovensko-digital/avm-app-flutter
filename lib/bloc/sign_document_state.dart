import 'package:autogram_sign/autogram_sign.dart' show SignDocumentResponseBody;
import 'package:flutter/foundation.dart';

import 'sign_document_cubit.dart';

/// State for [SignDocumentCubit].
@immutable
sealed class SignDocumentState {
  const SignDocumentState();

  SignDocumentLoadingState toLoading() {
    return const SignDocumentLoadingState();
  }

  SignDocumentCanceledState toCanceled() {
    return const SignDocumentCanceledState();
  }

  SignDocumentErrorState toError(Object error) {
    return SignDocumentErrorState(error);
  }

  SignDocumentSuccessState toSuccess(SignDocumentResponseBody signedDocument) {
    return SignDocumentSuccessState(signedDocument);
  }

  @override
  String toString() {
    return "$runtimeType()";
  }
}

class SignDocumentInitialState extends SignDocumentState {
  const SignDocumentInitialState();
}

class SignDocumentLoadingState extends SignDocumentState {
  const SignDocumentLoadingState();
}

class SignDocumentCanceledState extends SignDocumentState {
  const SignDocumentCanceledState();
}

class SignDocumentErrorState extends SignDocumentState {
  final Object error;

  const SignDocumentErrorState(this.error);

  @override
  String toString() {
    return "$runtimeType(error: $error)";
  }
}

class SignDocumentSuccessState extends SignDocumentState {
  final SignDocumentResponseBody signedDocument;

  const SignDocumentSuccessState(this.signedDocument);

  @override
  String toString() {
    return "$runtimeType(signedDocument: ${signedDocument.runtimeType}())";
  }
}
