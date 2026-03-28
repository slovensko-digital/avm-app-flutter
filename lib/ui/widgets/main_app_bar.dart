import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../app_theme.dart'
    show kMainAppBarForegroundColor, kMainAppBarBackgroundColor;

// ignore: non_constant_identifier_names
AppBar MainAppBar({
  required BuildContext context,
  VoidCallback? onMenuPressed,
}) {
  final strings = context.strings;
  final iconColor = Theme.of(context).colorScheme.onSecondary;

  final leadingButton = Semantics(
    button: true,
    excludeSemantics: true,
    label: strings.buttonMenuLabelSemantics,
    child: IconButton(
      icon: SvgPicture.asset(
        'assets/icons/menu.svg',
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
      onPressed: onMenuPressed,
    ),
  );

  return AppBar(
    foregroundColor: kMainAppBarForegroundColor,
    backgroundColor: kMainAppBarBackgroundColor,
    leading: leadingButton,
    title: Text(
      strings.appName,
      style: const TextStyle(color: kMainAppBarForegroundColor),
    ),
  );
}

@widgetbook.UseCase(path: '[AVM]', name: 'main', type: AppBar)
Widget previewMainAppBar(BuildContext context) {
  return SizedBox(
    height: kToolbarHeight,
    child: MainAppBar(
      context: context,
      onMenuPressed: () {
        developer.log("onMenuPressed");
      },
    ),
  );
}
