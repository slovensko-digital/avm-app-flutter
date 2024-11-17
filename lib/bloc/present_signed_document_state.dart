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

  PresentSignedLocalDocumentSuccessState toSuccess(File file) {
    return PresentSignedLocalDocumentSuccessState(file);
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

class PresentSignedLocalDocumentSuccessState
    extends PresentSignedDocumentState {
  final File file;

  const PresentSignedLocalDocumentSuccessState(this.file);

  @override
  String toString() {
    return "$runtimeType(file: $file)";
  }
}

class PresentSignedRemoteDocumentSuccessState
    extends PresentSignedDocumentState {
  const PresentSignedRemoteDocumentSuccessState();

  @override
  String toString() {
    return "$runtimeType()";
  }
}
