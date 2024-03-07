import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// "Autogram" logo.
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
  path: '[Core]',
  name: 'AutogramLogo',
  type: AutogramLogo,
)
Widget previewAutogramLogo(BuildContext context) {
  return const AutogramLogo();
}
