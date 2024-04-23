import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'retry_view.dart';

/// Widget for displaying some result with [icon] and [titleText].
///
/// Provides predefined: [ResultView.success], [ResultView.error] and
/// [ResultView.info].
///
/// See also:
///  - [RetryView]
class ResultView extends StatelessWidget {
  static const double _iconSize = 96;

  final ImageProvider icon;
  final String titleText;
  final Widget? body;

  const ResultView({
    super.key,
    required this.icon,
    required this.titleText,
    this.body,
  });

  const ResultView.success({
    super.key,
    required this.titleText,
    this.body,
  }) : icon = const AssetImage('assets/images/result_success.png');

  const ResultView.error({
    super.key,
    required this.titleText,
    this.body,
  }) : icon = const AssetImage('assets/images/result_error.png');

  const ResultView.info({
    super.key,
    required this.titleText,
    this.body,
  }) : icon = const AssetImage('assets/images/result_info.png');

  @override
  Widget build(BuildContext context) {
    final icon = Image(
      image: this.icon,
      width: _iconSize,
      height: _iconSize,
    );
    const headlineTextStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.15,
    );
    final headline = Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Text(
        titleText,
        textAlign: TextAlign.center,
        style: headlineTextStyle,
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        headline,
        if (body != null) body!,
      ],
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'info',
  type: ResultView,
)
Widget previewInfoResultView(BuildContext context) {
  return const Center(
    child: ResultView.info(
      titleText: "Operation failed successfully 😉",
      body: Text("Body text"),
    ),
  );
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'success',
  type: ResultView,
)
Widget previewSuccessResultView(BuildContext context) {
  return const Center(
    child: ResultView.success(
      titleText: "Operation was successful!",
      body: Text("Body text"),
    ),
  );
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'error',
  type: ResultView,
)
Widget previewErrorResultView(BuildContext context) {
  return const Center(
    child: ResultView.error(
      titleText: "Operation failed!",
      body: Text("Body text"),
    ),
  );
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'custom',
  type: ResultView,
)
Widget previewCustomResultView(BuildContext context) {
  return const Center(
    child: ResultView(
      icon: AssetImage('assets/images/notification.png'),
      titleText: "Title text here",
      body: Column(
        children: [
          Text("Body text 1"),
          Text("Body text 2"),
        ],
      ),
    ),
  );
}
