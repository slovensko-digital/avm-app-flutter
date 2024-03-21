import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../app_theme.dart';
import '../fragment/show_web_page_fragment.dart';
import '../widgets/step_indicator.dart';
import 'onboarding_screen.dart';

/// [OnboardingScreen] to accept Terms of Service document.
class OnboardingAcceptTermsOfServiceScreen extends StatefulWidget {
  final VoidCallback onTermsOfServiceAccepted;

  const OnboardingAcceptTermsOfServiceScreen({
    super.key,
    required this.onTermsOfServiceAccepted,
  });

  @override
  State<OnboardingAcceptTermsOfServiceScreen> createState() =>
      _OnboardingAcceptTermsOfServiceScreenState();
}

class _OnboardingAcceptTermsOfServiceScreenState
    extends State<OnboardingAcceptTermsOfServiceScreen> {
  final url = Uri.parse("https://slovensko.digital/o-nas/stanovy/");
  bool documentLoaded = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text("Podmienky používania"),
        ),
        body: _getBody(),
      ),
    );
  }

  Widget _getBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ShowWebPageFragment(
            url: url,
            onUrlLoaded: () {
              if (mounted) {
                setState(() {
                  documentLoaded = true;
                });
              }
            },
          ),
        ),

        // Steps
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: StepIndicator(stepNumber: 1, totalSteps: 3),
        ),

        // Primary button
        Padding(
          padding: kScreenMargin,
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: kPrimaryButtonMinimumSize,
            ),
            onPressed: documentLoaded ? widget.onTermsOfServiceAccepted : null,
            child: const Text("Súhlasím"),
          ),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'OnboardingAcceptTermsOfServiceScreen',
  type: OnboardingAcceptTermsOfServiceScreen,
)
Widget previewOnboardingAcceptTermsOfServiceScreen(BuildContext context) {
  return OnboardingAcceptTermsOfServiceScreen(
    onTermsOfServiceAccepted: () {
      developer.log("onTermsOfServiceAccepted");
    },
  );
}