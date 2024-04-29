import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

abstract interface class Asset {}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'icons',
  type: Asset,
)
Widget previewIcons(BuildContext context) {
  final files = [
    'menu.svg',
    'qr_code_scanner.svg',
  ];
  const double spacing = 8;

  return GridView.extent(
    primary: true,
    maxCrossAxisExtent: 64,
    mainAxisSpacing: spacing,
    crossAxisSpacing: spacing,
    children: [
      for (final file in files)
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            color: const Color(0xFFC0C0C0),
            child: SvgPicture.asset(
              "assets/icons/$file",
            ),
          ),
        )
    ],
  );
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'images',
  type: Asset,
)
Widget previewImages(BuildContext context) {
  final files = [
    'close.svg',
    'danger.svg',
    'info.svg',
    'lock.svg',
    'notification.svg',
    'tick.svg',
  ];
  const double spacing = 8;

  return GridView.extent(
    primary: true,
    maxCrossAxisExtent: 140,
    padding: const EdgeInsets.all(spacing),
    mainAxisSpacing: spacing,
    crossAxisSpacing: spacing,
    childAspectRatio: 0.65,
    children: [
      for (final file in files)
        Container(
          color: const Color(0xFFC0C0C0),
          child: Column(
            children: [
              SvgPicture.asset(
                "assets/images/$file",
                width: 120,
                height: 120,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  file,
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        )
    ],
  );
}
