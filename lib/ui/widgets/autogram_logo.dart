import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// "Autogram" logo.
///
/// Only for light theme!
class AutogramLogo extends StatelessWidget {
  final double? width;

  const AutogramLogo({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return Image(
      image: const AssetImage('assets/images/autogram_logo.png'),
      width: width,
    );
  }
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'AutogramLogo',
  type: AutogramLogo,
)
Widget previewAutogramLogo(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: Center(child: AutogramLogo()),
  );
}
