import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Widget for displaying indeterminate loading indicator.
class LoadingIndicator extends StatelessWidget {
  final int size;
  final Color color;
  final Color backgroundColor;

  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.color = const Color(0xFF126dff),
    this.backgroundColor = const Color(0xFFc3d9f9),
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: size / 36, // _kMinCircularProgressIndicatorSize is 36
      child: CircularProgressIndicator(
        color: color,
        backgroundColor: backgroundColor,
        strokeWidth: 6,
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'LoadingIndicator',
  type: LoadingIndicator,
)
Widget previewLoadingIndicator(BuildContext context) {
  return const Center(
    child: LoadingIndicator(),
  );
}
