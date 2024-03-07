import 'dart:io' show File;

import 'package:flutter/foundation.dart';

import 'create_document_cubit.dart';

/// State for [CreateDocumentCubit].
@immutable
sealed class CreateDocumentState {
  final File file;

  const CreateDocumentState(this.file);

  CreateDocumentLoadingState toLoading() {
    return CreateDocumentLoadingState(file);
  }

  CreateDocumentSuccessState toSuccess(String documentId) {
    return CreateDocumentSuccessState(file, documentId);
  }

  CreateDocumentErrorState toError(Object error) {
    return CreateDocumentErrorState(file, error);
  }

  @override
  String toString() {
    return "$runtimeType(file: $file)";
  }
}

class CreateDocumentInitialState extends CreateDocumentState {
  const CreateDocumentInitialState(super.file);
}

class CreateDocumentLoadingState extends CreateDocumentState {
  const CreateDocumentLoadingState(super.file);
}

class CreateDocumentErrorState extends CreateDocumentState {
  final Object error;

  const CreateDocumentErrorState(super.file, this.error);

  @override
  String toString() {
    return "$runtimeType(error: $error)";
  }
}

class CreateDocumentSuccessState extends CreateDocumentState {
  final String documentId;

  const CreateDocumentSuccessState(super.file, this.documentId);

  @override
  String toString() {
    return "$runtimeType(documentId: $documentId)";
  }
}
