import 'dart:async';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:widgetbook/widgetbook.dart' show KnobsExtension;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'html_preview.dart';

/// Displays plain text with a document-like appearance (gradient background,
/// white paper box with shadow).
///
/// See also:
///  - [HtmlPreview]
///  - [PdfPreview]
class PlainTextPreview extends StatelessWidget {
  final FutureOr<String> source;

  const PlainTextPreview({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final source = this.source;

    if (source is String) {
      return _buildContent(source);
    }

    return FutureBuilder<String>(
      future: source,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        return _buildContent(snapshot.data ?? '');
      },
    );
  }

  Widget _buildContent(String text) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBDBDBD), Color(0xFFEEEEEE)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: LayoutBuilder(
          builder: (context, constraints) => Container(
            constraints: BoxConstraints(
              minHeight: constraints.maxWidth * (297 / 210),
            ),
            // Same decoration as PdfPreview -> PdfPreviewPageData
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(offset: Offset(0, 3), blurRadius: 5),
              ],
            ),
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'normal',
  type: PlainTextPreview,
)
Widget previewPlainTextPreview(BuildContext context) {
  final text = context.knobs.string(
    label: 'Text',
    initialValue:
        'Utilitatis causa amicitia est quaesita.\nLorem ipsum dolor sit amet, consectetur adipiscing elit.\n\nCollatio igitur ista te nihil iuvat.',
    maxLines: 20,
  );

  return PlainTextPreview(source: text);
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'error',
  type: PlainTextPreview,
)
Widget previewPlainTextPreviewError(BuildContext context) {
  final error = Exception('Failed to load document');

  return PlainTextPreview(source: Future.error(error));
}
