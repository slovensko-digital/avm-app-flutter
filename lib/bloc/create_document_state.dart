import 'dart:io' show File;

import 'package:flutter/foundation.dart';

import 'create_document_cubit.dart';

/// State for [CreateDocumentCubit].
@immutable
sealed class CreateDocumentState {
  const CreateDocumentState();

  CreateDocumentLoadingState toLoading() {
    return const CreateDocumentLoadingState();
  }

  CreateDocumentSuccessState toSuccess(File file, String documentId) {
    return CreateDocumentSuccessState(file, documentId);
  }

  CreateDocumentErrorState toError(Object error) {
    return CreateDocumentErrorState(error);
  }

  @override
  String toString() {
    return "$runtimeType()";
  }
}

class CreateDocumentInitialState extends CreateDocumentState {
  const CreateDocumentInitialState();
}

class CreateDocumentLoadingState extends CreateDocumentState {
  const CreateDocumentLoadingState();
}

class CreateDocumentErrorState extends CreateDocumentState {
  final Object error;

  const CreateDocumentErrorState(this.error);

  @override
  String toString() {
    return "$runtimeType(error: $error)";
  }
}

class CreateDocumentSuccessState extends CreateDocumentState {
  final File file;
  final String documentId;

  const CreateDocumentSuccessState(this.file, this.documentId);

  @override
  String toString() {
    return "$runtimeType(file: $file, documentId: $documentId)";
  }
}
