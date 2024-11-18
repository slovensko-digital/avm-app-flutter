import 'package:autogram_sign/autogram_sign.dart'
    show DocumentValidationResponseBody;
import 'package:flutter/foundation.dart';

import 'document_validation_cubit.dart';

/// State for [DocumentValidationCubit].
@immutable
sealed class DocumentValidationState {
  const DocumentValidationState();

  @override
  String toString() {
    return "$runtimeType()";
  }
}

class DocumentValidationInitialState extends DocumentValidationState {
  const DocumentValidationInitialState();
}

class DocumentValidationLoadingState extends DocumentValidationState {
  const DocumentValidationLoadingState();
}

class DocumentValidationErrorState extends DocumentValidationState {
  final Object error;

  const DocumentValidationErrorState(this.error);

  @override
  String toString() {
    return "$runtimeType(error: $error)";
  }
}

class DocumentValidationNotSignedState extends DocumentValidationState {
  const DocumentValidationNotSignedState();
}

class DocumentValidationSuccessState extends DocumentValidationState {
  final DocumentValidationResponseBody response;

  const DocumentValidationSuccessState(this.response);

  @override
  String toString() {
    return "$runtimeType(response: $response)";
  }
}
