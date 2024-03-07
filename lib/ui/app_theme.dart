import 'package:flutter/material.dart';

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

  return ThemeData(
    useMaterial3: true,
    primaryColor: color,
    colorScheme: colorScheme,
  );
}
