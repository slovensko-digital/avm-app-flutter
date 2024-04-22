import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../util/errors.dart';
import 'loading_content.dart';
import 'result_view.dart';

/// Displays error result in [ResultView.error].
///
/// See also:
///  - [LoadingContent]
class ErrorContent extends StatelessWidget {
  final String title;
  final Object error;

  const ErrorContent({super.key, required this.title, required this.error});

  @override
  Widget build(BuildContext context) {
    final message = getErrorMessage(error);

    return Center(
      child: ResultView.error(
        titleText: title,
        body: Text(message),
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'ErrorContent',
  type: ErrorContent,
)
Widget previewErrorContent(BuildContext context) {
  return ErrorContent(
    title: "Nadpis pre chybu",
    error: Exception("Some error text!"),
  );
}
