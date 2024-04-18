import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../app_theme.dart';
import '../widgets/result_view.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';

/// [OnboardingScreen] to display some information when finished.
///
/// See also:
///  - [MainScreen]
class OnboardingFinishedScreen extends StatelessWidget {
  final VoidCallback? onStartRequested;

  const OnboardingFinishedScreen({
    super.key,
    required this.onStartRequested,
  });

  @override
  Widget build(BuildContext context) {
    final child = Column(
      children: [
        const Expanded(
          child: ResultView.success(
            titleText: "Autogram je pripravený",
            body: Text(
              "Začnite výberom dokumentu na:\n ✅ Jednoduché podpisovanie",
            ),
          ),
        ),

        // Primary button
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: onStartRequested,
          child: Text(context.strings.buttonOpenDocumentLabel),
        ),
      ],
    );

    final body = Padding(
      padding: kScreenMargin,
      child: child,
    );

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: body,
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'OnboardingFinishedScreen',
  type: OnboardingFinishedScreen,
)
Widget previewOnboardingFinishedScreen(BuildContext context) {
  return OnboardingFinishedScreen(
    onStartRequested: () {
      developer.log("onStartRequested");
    },
  );
}
