import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'retry_view.dart';

/// Widget for displaying [ResultView.success] or [ResultView.error] result.
///
/// See also:
///  - [RetryView]
class ResultView extends StatelessWidget {
  static const double _iconSize = 96;

  final Widget icon;
  final String headlineText;
  final Widget? body;

  const ResultView({
    super.key,
    required this.icon,
    required this.headlineText,
    this.body,
  });

  const ResultView.success({
    super.key,
    required this.headlineText,
    this.body,
  }) : icon = const Image(
          image: AssetImage('assets/images/result_success.png'),
          width: _iconSize,
          height: _iconSize,
        );

  const ResultView.error({
    super.key,
    required this.headlineText,
    this.body,
  }) : icon = const Image(
          image: AssetImage('assets/images/result_error.png'),
          width: _iconSize,
          height: _iconSize,
        );

  @override
  Widget build(BuildContext context) {
    const headlineTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );

    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              headlineText,
              textAlign: TextAlign.center,
              style: headlineTextStyle,
            ),
          ),
          if (body != null) body!,
        ],
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'success',
  type: ResultView,
)
Widget previewSuccessResultView(BuildContext context) {
  return const ResultView.success(
    headlineText: "Operation was successful!",
    body: Text("Body text"),
  );
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'error',
  type: ResultView,
)
Widget previewErrorResultView(BuildContext context) {
  return const ResultView.error(
    headlineText: "Operation failed!",
    body: Text("Body text"),
  );
}
