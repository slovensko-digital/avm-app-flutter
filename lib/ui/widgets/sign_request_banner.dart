import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';

/// Returns [MaterialBanner] that offers to open new sign request, which came
/// while another screen is open.
///
/// Show it using [ScaffoldMessengerState.showMaterialBanner].
///
/// Unlike [SnackBar], it's on top, so it doesn't cover bottom buttons
/// (e.g. "Sign"), and it stays until user taps [onOpenPressed] or
/// [onDismissPressed] - there is no timeout or hidden swipe gesture.
/// Screen readers announce it as a live region.
MaterialBanner signRequestBanner(
  BuildContext context, {
  required VoidCallback onOpenPressed,
  required VoidCallback onDismissPressed,
}) {
  final strings = context.strings;
  final theme = Theme.of(context);
  final colors = theme.colorScheme;

  return MaterialBanner(
    backgroundColor: colors.primaryContainer,
    surfaceTintColor: Colors.transparent,
    dividerColor: Colors.transparent,
    leading: Icon(
      Icons.notifications_active_outlined,
      color: colors.onPrimaryContainer,
    ),
    contentTextStyle: theme.textTheme.bodyMedium?.copyWith(
      color: colors.onPrimaryContainer,
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          strings.newSignRequestTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(strings.newSignRequestMessage),
      ],
    ),
    actions: [
      TextButton(
        style: TextButton.styleFrom(
          foregroundColor: colors.onPrimaryContainer,
        ),
        onPressed: onDismissPressed,
        child: Text(strings.buttonCloseLabel),
      ),
      FilledButton(
        onPressed: onOpenPressed,
        child: Text(strings.openSignRequestLabel),
      ),
    ],
  );
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'sign request',
  type: MaterialBanner,
)
Widget previewSignRequestBanner(BuildContext context) {
  return Align(
    alignment: Alignment.topCenter,
    child: signRequestBanner(
      context,
      onOpenPressed: () {
        developer.log("onOpenPressed");
      },
      onDismissPressed: () {
        developer.log("onDismissPressed");
      },
    ),
  );
}
