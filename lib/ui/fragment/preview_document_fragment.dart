import 'package:autogram_sign/autogram_sign.dart'
    show DocumentVisualizationResponseBody;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/preview_document_cubit.dart';
import '../../strings_context.dart';
import '../widgets/document_visualization.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';

/// Displays Document preview based on the [state].
///
/// See [PreviewDocumentCubit].
class PreviewDocumentFragment extends StatelessWidget {
  final PreviewDocumentState state;

  const PreviewDocumentFragment({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      PreviewDocumentInitialState _ => const LoadingContent(),
      PreviewDocumentLoadingState _ => const LoadingContent(),
      PreviewDocumentSuccessState state => _SuccessContent(
          visualization: state.visualization,
        ),
      PreviewDocumentErrorState state => ErrorContent(
          title: context.strings.previewDocumentErrorHeading,
          error: state.error,
        ),
    };
  }
}

/// Displays [visualization] using [DocumentVisualization] with dotted border.
class _SuccessContent extends StatelessWidget {
  final DocumentVisualizationResponseBody visualization;

  const _SuccessContent({required this.visualization});

  @override
  Widget build(BuildContext context) {
    final dashColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: DottedBorder(
        color: dashColor,
        strokeWidth: 4,
        dashPattern: const [16, 16],
        padding: EdgeInsets.zero,
        child: DocumentVisualization(
          visualization: visualization,
        ),
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Fragments]',
  name: 'loading',
  type: PreviewDocumentFragment,
)
Widget previewLoadingPreviewDocumentFragment(BuildContext context) {
  return const PreviewDocumentFragment(
    state: PreviewDocumentLoadingState(),
  );
}

@widgetbook.UseCase(
  path: '[Fragments]',
  name: 'error',
  type: PreviewDocumentFragment,
)
Widget previewErrorPreviewDocumentScreen(BuildContext context) {
  return const PreviewDocumentFragment(
    state: PreviewDocumentErrorState("Error message!"),
  );
}

@widgetbook.UseCase(
  path: '[Fragments]',
  name: 'success',
  type: PreviewDocumentFragment,
)
Widget previewSuccessPreviewDocumentScreen(BuildContext context) {
  return const PreviewDocumentFragment(
    state: PreviewDocumentSuccessState(
      DocumentVisualizationResponseBody(
        mimeType: "text/plain;base64",
        filename: "sample.txt",
        content: "",
      ),
    ),
  );
}
