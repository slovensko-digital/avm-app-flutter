import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../app_theme.dart';
import '../widgets/step_indicator.dart';
import 'onboarding_screen.dart';

/// [OnboardingScreen] to select and store signing certificate.
class OnboardingSelectCertificateScreen extends StatelessWidget {
  const OnboardingSelectCertificateScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // TODO Impl OnboardingSelectCertificateScreen with its Cubit
    final child = Column(
      children: [
        const Expanded(
          child: Text("### body ###"),
        ),

        // Steps
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 16),
          child: StepIndicator(stepNumber: 2, totalSteps: 3),
        ),

        // Primary button
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: null,
          child: const Text("Vybrať certifikát"),
        ),
      ],
    );

    final body = Padding(
      padding: kScreenMargin,
      child: child,
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text("Výber podpisového certifikátu"),
        ),
        body: body,
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'OnboardingSelectCertificateScreen',
  type: OnboardingSelectCertificateScreen,
)
Widget previewOnboardingSelectCertificateScreen(BuildContext context) {
  return const OnboardingSelectCertificateScreen();
}
