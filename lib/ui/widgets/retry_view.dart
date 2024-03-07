import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'result_view.dart';

/// Widget for displaying [text] and "Retry" button
///
/// See also:
///  - [ResultView]
class RetryView extends StatelessWidget {
  final String headlineText;
  final VoidCallback? onRetryRequested;

  const RetryView({
    super.key,
    required this.headlineText,
    this.onRetryRequested,
  });

  @override
  Widget build(BuildContext context) {
    const headlineTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            headlineText,
            textAlign: TextAlign.center,
            style: headlineTextStyle,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onRetryRequested,
            icon: const Icon(Icons.refresh_outlined),
            label: const Text("Zopakovať"),
          ),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'RetryView',
  type: RetryView,
)
Widget previewRetryView(BuildContext context) {
  return RetryView(
    headlineText: "Headline text",
    onRetryRequested: () {},
  );
}
