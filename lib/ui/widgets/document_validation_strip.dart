import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import 'loading_indicator.dart';
import 'markdown_text.dart';

/// Presents state of Document validation - displays text and potentially
/// loading indicator on the left and on the right one of the:
/// - arrow on the right when has any signatures
/// - × when has no signatures
///
/// [onTap] is called when taped on whole widget.
class DocumentValidationStrip extends StatelessWidget {
  final DocumentValidationStripValue value;
  final VoidCallback? onTap;

  const DocumentValidationStrip({
    super.key,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final data = (
      value.isLoading,
      value.failedCount,
      value.indeterminateCount,
      value.passedCount
    );
    final isLoading = value.isLoading;
    final hasSignatures =
        (value.failedCount + value.indeterminateCount + value.passedCount) > 0;
    final strings = context.strings;
    final (String text, Color backgroundColor) = switch (data) {
      (true, _, _, _) => (
          strings.documentValidationLoadingLabel,
          const Color(0xFF126DFF)
        ),
      (false, 0, 0, 0) => (
          strings.documentValidationNoSignaturesLabel,
          const Color(0xFF126DFF),
        ),
      (false, > 0, _, _) => (
          strings.documentValidationHasInvalidSignaturesLabel,
          const Color(0xFFC3112B),
        ),
      (false, _, > 0, _) => (
          strings.documentValidationHasIndeterminateSignatureLabel,
          const Color(0xFFbd730c),
        ),
      (false, 0, 0, > 0) => (
          strings.documentValidationHasValidSignaturesLabel(value.passedCount),
          const Color(0xFF078814),
        ),
      (_, _, _, _) => ("", Colors.transparent), // technically invalid case
    };
    const foregroundColor = Colors.white;
    final icon = (hasSignatures ? Icons.arrow_right_alt_outlined : Icons.close);

    final children = [
      if (isLoading) const LoadingIndicator(size: 16),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: MarkdownText(text, textColor: foregroundColor),
        ),
      ),
      Icon(
        icon,
        color: foregroundColor,
        semanticLabel: null,
      )
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        color: backgroundColor,
        child: Row(
          children: children,
        ),
      ),
    );
  }
}

/// Value for [DocumentValidationStrip] widget.
class DocumentValidationStripValue {
  final bool isLoading;
  final int failedCount;
  final int indeterminateCount;
  final int passedCount;
  final Object? error;

  const DocumentValidationStripValue.loading()
      : isLoading = true,
        failedCount = 0,
        indeterminateCount = 0,
        passedCount = 0,
        error = null;

  const DocumentValidationStripValue.value({
    required this.failedCount,
    required this.indeterminateCount,
    required this.passedCount,
  })  : isLoading = false,
        error = null;

  const DocumentValidationStripValue.none()
      : this.value(
          failedCount: 0,
          indeterminateCount: 0,
          passedCount: 0,
        );
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'loading',
  type: DocumentValidationStrip,
)
Widget previewLoadingDocumentValidationStrip(BuildContext context) {
  return const DocumentValidationStrip(
    value: DocumentValidationStripValue.loading(),
  );
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'signatures',
  type: DocumentValidationStrip,
)
Widget previewOtherDocumentValidationStrip(BuildContext context) {
  final passedCount = context.knobs.list(
    label: 'Passed count',
    options: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    initialOption: 0,
  );
  final indeterminateCount = context.knobs.list(
    label: 'Indeterminate count',
    options: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    initialOption: 0,
  );
  final failedCount = context.knobs.list(
    label: 'Failed count',
    options: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    initialOption: 0,
  );

  return DocumentValidationStrip(
    value: DocumentValidationStripValue.value(
      failedCount: failedCount,
      indeterminateCount: indeterminateCount,
      passedCount: passedCount,
    ),
  );
}
