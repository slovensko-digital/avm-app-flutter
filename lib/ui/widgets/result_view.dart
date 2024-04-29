import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:widgetbook/widgetbook.dart';
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
  static const double _iconSize = 120;

  /// SVG asset
  final String icon;

  /// Title text.
  final String titleText;

  /// Body widget.
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
  }) : icon = 'assets/images/tick.svg';

  const ResultView.error({
    super.key,
    required this.titleText,
    this.body,
  }) : icon = 'assets/images/danger.svg';

  const ResultView.info({
    super.key,
    required this.titleText,
    this.body,
  }) : icon = 'assets/images/info.svg';

  @override
  Widget build(BuildContext context) {
    final icon = SvgPicture.asset(
      this.icon,
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
  final title = context.knobs.string(
    label: "Title",
    maxLines: 2,
    initialValue: "Operation failed successfully 😉",
  );
  final body = context.knobs.string(
    label: "Body",
    maxLines: 5,
    initialValue: "Body text",
  );

  return Center(
    child: ResultView.info(
      titleText: title,
      body: Text(body),
    ),
  );
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'success',
  type: ResultView,
)
Widget previewSuccessResultView(BuildContext context) {
  final title = context.knobs.string(
    label: "Title",
    maxLines: 2,
    initialValue: "Operation was successful!",
  );
  final body = context.knobs.string(
    label: "Body",
    maxLines: 5,
    initialValue: "Body text",
  );

  return Center(
    child: ResultView.success(
      titleText: title,
      body: Text(body),
    ),
  );
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'error',
  type: ResultView,
)
Widget previewErrorResultView(BuildContext context) {
  final title = context.knobs.string(
    label: "Title",
    maxLines: 2,
    initialValue: "Operation was successful!",
  );
  final body = context.knobs.string(
    label: "Body",
    maxLines: 5,
    initialValue: "Body text",
  );

  return Center(
    child: ResultView.error(
      titleText: title,
      body: Text(body),
    ),
  );
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'custom',
  type: ResultView,
)
Widget previewCustomResultView(BuildContext context) {
  final title = context.knobs.string(
    label: "Title",
    maxLines: 2,
    initialValue: "Operation was successful!",
  );
  final body = context.knobs.string(
    label: "Body",
    maxLines: 5,
    initialValue: "Body text 1\nBody text 2.\nBody text 3.",
  );

  return Center(
    child: ResultView(
      icon: 'assets/images/notification.svg',
      titleText: title,
      body: Column(
        children: [
          Text(body),
        ],
      ),
    ),
  );
}
