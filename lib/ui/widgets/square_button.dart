import 'package:flutter/material.dart';

/// Simple square size button.
// ignore: non_constant_identifier_names
Widget SquareButton({
  required VoidCallback? onPressed,
  Color? backgroundColor,
  required Widget child,
}) {
  const size = Size.square(kMinInteractiveDimension);

  return FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      minimumSize: size,
      padding: EdgeInsets.zero,
      backgroundColor: backgroundColor,
    ),
    child: child,
  );
}
