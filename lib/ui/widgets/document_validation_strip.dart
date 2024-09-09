import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import 'loading_indicator.dart';
import 'markdown_text.dart';

/// Presents state of document validation - displays text and potentionally
/// loading indicator on the left or arrow on the right when has any signatures.
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
    final data = (value.isLoading, value.validCount, value.invalidCount);
    final isLoading = value.isLoading;
    final hasSignatures = (value.validCount > 0 || value.invalidCount > 0);

    final strings = context.strings;

    final String text = switch (data) {
      (true, _, _) => strings.documentValidationLoadingLabel,
      (false, _, > 0) => strings.documentValidationHasInvalidSignaturesLabel,
      (false, > 0, _) =>
        strings.documentValidationHasValidSignaturesLabel(value.validCount),
      (false, 0, 0) => strings.documentValidationNoSignaturesLabel,
      (_, _, _) => "" // technically invalid case
    };
    final Color backgroundColor = switch (data) {
      (true, _, _) => const Color(0xFF126DFF),
      (false, _, > 0) => const Color(0xFFC3112B),
      (false, > 0, _) => const Color(0xFF078814),
      (false, 0, 0) => const Color(0xFF126DFF),
      (_, _, _) => Colors.transparent,
    };
    const foregroundColor = Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        color: backgroundColor,
        child: Row(
          children: [
            if (isLoading) const LoadingIndicator(size: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: MarkdownText(text, textColor: foregroundColor),
              ),
            ),
            if (hasSignatures)
              const Icon(
                Icons.arrow_right_alt_outlined,
                color: foregroundColor,
              )
          ],
        ),
      ),
    );
  }
}

/// Value for [DocumentValidationStrip] widget.
class DocumentValidationStripValue {
  final bool isLoading;
  final int validCount;
  final int invalidCount;

  const DocumentValidationStripValue.loading()
      : isLoading = true,
        validCount = 0,
        invalidCount = 0;

  const DocumentValidationStripValue.value({
    required this.validCount,
    required this.invalidCount,
  }) : isLoading = false;

  const DocumentValidationStripValue.none()
      : validCount = 0,
        invalidCount = 0,
        isLoading = false;
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
  final validCount = context.knobs.list(
    label: 'Valid count',
    options: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    initialOption: 0,
  );
  final invalidCount = context.knobs.list(
    label: 'Invalid count',
    options: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    initialOption: 0,
  );

  return DocumentValidationStrip(
    value: DocumentValidationStripValue.value(
      validCount: validCount,
      invalidCount: invalidCount,
    ),
  );
}
