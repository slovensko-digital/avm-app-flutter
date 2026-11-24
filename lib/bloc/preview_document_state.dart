import 'package:autogram_sign/autogram_sign.dart'
    show VerifiableVisualizationResponseBody;
import 'package:flutter/foundation.dart';

import '../data/document_preview.dart';
import 'preview_document_cubit.dart';

/// State for [PreviewDocumentCubit].
@immutable
sealed class PreviewDocumentState {
  const PreviewDocumentState();

  PreviewDocumentLoadingState toLoading() {
    return const PreviewDocumentLoadingState();
  }

  PreviewDocumentSuccessState toSuccess(
    VerifiableVisualizationResponseBody visualization,
    DocumentPreview preview,
  ) {
    return PreviewDocumentSuccessState(visualization, preview);
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
  /// Data objects covered by the signature, needed to verify data to sign.
  final VerifiableVisualizationResponseBody visualization;

  /// Document visualized on the device from the [visualization].
  final DocumentPreview preview;

  const PreviewDocumentSuccessState(this.visualization, this.preview);

  @override
  String toString() {
    return "$runtimeType(preview: ${preview.runtimeType})";
  }
}
