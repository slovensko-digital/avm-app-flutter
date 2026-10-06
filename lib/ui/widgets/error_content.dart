import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../util/errors.dart';
import 'loading_content.dart';
import 'result_view.dart';

/// Displays error result in [ResultView.error].
///
/// Optionally displays an action button below the error message.
///
/// See also:
///  - [LoadingContent]
class ErrorContent extends StatelessWidget {
  final String title;
  final Object error;
  final String? actionButtonLabel;
  final VoidCallback? onActionPressed;

  const ErrorContent({
    super.key,
    required this.title,
    required this.error,
    this.actionButtonLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final message = getErrorMessage(error);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ResultView.error(
                titleText: title,
                body: Text(message),
              ),
              if (actionButtonLabel != null && onActionPressed != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onActionPressed,
                    child: Text(actionButtonLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
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

@widgetbook.UseCase(
  path: '[Core]',
  name: 'ErrorContent with action button',
  type: ErrorContent,
)
Widget previewErrorContentWithButton(BuildContext context) {
  return ErrorContent(
    title: "Nadpis pre chybu spolu s tlačidlom",
    error: Exception("Some error text with button!"),
    actionButtonLabel: "Nadpis pre tlačidlo",
    onActionPressed: () {},
  );
}
