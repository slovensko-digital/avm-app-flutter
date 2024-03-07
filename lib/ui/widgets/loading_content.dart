import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'error_content.dart';
import 'loading_indicator.dart';

/// Displays loading indicator in center.
///
/// See also:
///  - [ErrorContent]
class LoadingContent extends StatelessWidget {
  const LoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: LoadingIndicator());
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'LoadingContent',
  type: LoadingContent,
)
Widget previewLoadingContent(BuildContext context) {
  return const LoadingContent();
}
