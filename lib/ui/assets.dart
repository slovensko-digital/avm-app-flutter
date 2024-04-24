import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  path: '[AVM]',
  name: '',
  type: Icon,
)
Widget previewIcons(BuildContext context) {
  final icons = [
    'assets/icons/menu.svg',
    'assets/icons/qr_code_scanner.svg',
  ];
  const double spacing = 16;

  return GridView.extent(
    primary: true,
    maxCrossAxisExtent: 64,
    mainAxisSpacing: spacing,
    crossAxisSpacing: spacing,
    children: [
      for (final icon in icons)
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            color: const Color(0xFFC0C0C0),
            child: SvgPicture.asset(
              icon,
            ),
          ),
        )
    ],
  );
}
