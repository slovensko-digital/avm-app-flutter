import 'dart:io' show File;

import 'package:flutter/foundation.dart';

/// State for [PresentSignedDocumentCubit].
@immutable
sealed class PresentSignedDocumentState {
  const PresentSignedDocumentState();

  PresentSignedDocumentLoadingState toLoading() {
    return const PresentSignedDocumentLoadingState();
  }

  PresentSignedDocumentErrorState toError(Object error) {
    return PresentSignedDocumentErrorState(error);
  }

  PresentSignedDocumentSuccessState toSuccess(File file) {
    return PresentSignedDocumentSuccessState(file);
  }

  @override
  String toString() {
    return "$runtimeType()";
  }
}

class PresentSignedDocumentInitialState extends PresentSignedDocumentState {
  const PresentSignedDocumentInitialState();
}

class PresentSignedDocumentLoadingState extends PresentSignedDocumentState {
  const PresentSignedDocumentLoadingState();
}

class PresentSignedDocumentErrorState extends PresentSignedDocumentState {
  final Object error;

  const PresentSignedDocumentErrorState(this.error);

  @override
  String toString() {
    return "$runtimeType(error: $error)";
  }
}

class PresentSignedDocumentSuccessState extends PresentSignedDocumentState {
  final File file;

  const PresentSignedDocumentSuccessState(this.file);

  @override
  String toString() {
    return "$runtimeType(file: $file)";
  }
}
