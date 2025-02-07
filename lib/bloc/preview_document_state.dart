import 'package:autogram_sign/autogram_sign.dart'
    show DocumentVisualizationResponseBody;
import 'package:flutter/foundation.dart';

import 'preview_document_cubit.dart';

/// State for [PreviewDocumentCubit].
@immutable
sealed class PreviewDocumentState {
  const PreviewDocumentState();

  // TODO Cleanup these
  PreviewDocumentLoadingState toLoading() {
    return const PreviewDocumentLoadingState();
  }

  PreviewDocumentSuccessState toSuccess(
      DocumentVisualizationResponseBody visualization) {
    return PreviewDocumentSuccessState(visualization);
  }

  PreviewDocumentErrorState toError(Object error) {
    return PreviewDocumentErrorState(error);
  }

  @override
  String toString() {
    return "$runtimeType()";
  }
}

class PreviewDocumentInitialState extends PreviewDocumentState {
  const PreviewDocumentInitialState();
}

class PreviewDocumentLoadingState extends PreviewDocumentState {
  const PreviewDocumentLoadingState();
}

class PreviewDocumentErrorState extends PreviewDocumentState {
  final Object error;

  const PreviewDocumentErrorState(this.error);

  @override
  String toString() {
    return "$runtimeType(error: $error)";
  }
}

class PreviewDocumentSuccessState extends PreviewDocumentState {
  final DocumentVisualizationResponseBody visualization;

  const PreviewDocumentSuccessState(this.visualization);

  @override
  String toString() {
    return "$runtimeType(visualization: ...)";
  }
}
