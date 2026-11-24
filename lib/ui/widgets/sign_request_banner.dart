import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../app_theme.dart';

/// Returns [MaterialBanner] that offers to open new sign request, which came
/// while another screen is open.
///
/// Show it using [ScaffoldMessengerState.showMaterialBanner].
///
/// It's dark strip in colors of the main app bar under the app bar, so it
/// doesn't cover bottom buttons (e.g. "Sign"), and it stays until user taps
/// [onOpenPressed] or [onDismissPressed] - there is no timeout or hidden swipe
/// gesture. The actions are beside the text, or below it on narrow phones
/// and with large font.
/// Screen readers announce it as a live region.
MaterialBanner signRequestBanner(
  BuildContext context, {
  required VoidCallback onOpenPressed,
  required VoidCallback onDismissPressed,
}) {
  const foregroundColor = kMainAppBarForegroundColor;
  const messageColor = Color(0xFFC3D9F9); // ID-SK "Základná médium"
  final strings = context.strings;
  final theme = Theme.of(context);
  // Beside the text, actions leave too little space for it on narrow phones
  // and with large font
  final textScale = MediaQuery.textScalerOf(context).scale(1);
  final actionsBelow = MediaQuery.sizeOf(context).width < 390 * textScale;

  return MaterialBanner(
    backgroundColor: kMainAppBarBackgroundColor,
    surfaceTintColor: Colors.transparent,
    dividerColor: Colors.transparent,
    forceActionsBelow: actionsBelow,
    // MaterialBanner has no space below the text beside the actions
    padding: actionsBelow
        ? null
        : const EdgeInsetsDirectional.only(start: 16, top: 8, bottom: 8),
    leading: const Icon(
      Icons.notifications_active_outlined,
      color: foregroundColor,
    ),
    contentTextStyle: theme.textTheme.bodyMedium?.copyWith(
      color: messageColor,
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          strings.newSignRequestTitle,
          style: const TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(strings.newSignRequestMessage),
      ],
    ),
    actions: [
      // Single action, so it's beside the content
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: foregroundColor,
              // as other buttons in the app, see appTheme
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              side: const BorderSide(color: foregroundColor, width: 2),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            onPressed: onOpenPressed,
            child: Text(strings.openSignRequestLabel),
          ),
          IconButton(
            color: foregroundColor,
            tooltip: strings.buttonCloseLabel,
            onPressed: onDismissPressed,
            icon: const Icon(Icons.close),
          ),
        ],
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
