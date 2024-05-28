import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../app_theme.dart';
import '../onboarding.dart';
import '../widgets/result_view.dart';

/// [Onboarding] screen to display some information when finished.
///
/// See also:
///  - [MainScreen]
class OnboardingFinishedScreen extends StatelessWidget {
  final ValueSetter<BuildContext>? onStartRequested;

  const OnboardingFinishedScreen({
    super.key,
    required this.onStartRequested,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final child = Column(
      children: [
        Expanded(
          child: ResultView.success(
            titleText: strings.onboardingFinishedHeading,
            body: Text(strings.onboardingFinishedBody),
          ),
        ),

        // Primary button
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: onStartRequested != null
              ? () {
                  onStartRequested?.call(context);
                }
              : null,
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
  name: '',
  type: OnboardingFinishedScreen,
)
Widget previewOnboardingFinishedScreen(BuildContext context) {
  return OnboardingFinishedScreen(
    onStartRequested: (_) {
      developer.log("onStartRequested");
    },
  );
}
