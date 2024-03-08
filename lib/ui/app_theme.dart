import 'package:flutter/material.dart';

const EdgeInsets kScreenMargin = EdgeInsets.all(16);

const Size kPrimaryButtonMinimumSize = Size.fromHeight(60);

/// Returns M3 [ThemeData].
ThemeData appTheme(
  BuildContext context, {
  Brightness? brightness,
}) {
  const color = Color(0xFF126DFF);
  final colorScheme = ColorScheme.fromSeed(
    brightness: brightness ?? MediaQuery.platformBrightnessOf(context),
    seedColor: color,
  );
  final dialogTheme = DialogTheme(
    surfaceTintColor: colorScheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
  );

  return ThemeData(
    useMaterial3: true,
    primaryColor: color,
    colorScheme: colorScheme,
    dialogTheme: dialogTheme,
  );
}
