import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../data/settings.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import '../fragment/show_web_page_fragment.dart';
import '../widgets/step_indicator.dart';
import 'onboarding_screen.dart';

/// [OnboardingScreen] to accept Terms of Service document.
///
/// Saves version into [ISettings.acceptedTermsOfServiceVersion].
///
/// Consumes [ISettings].
class OnboardingAcceptTermsOfServiceScreen extends StatefulWidget {
  final VoidCallback onCanceled;
  final VoidCallback onTermsOfServiceAccepted;

  const OnboardingAcceptTermsOfServiceScreen({
    super.key,
    required this.onCanceled,
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
    return Scaffold(
      appBar: AppBar(
        // Need to add BackButton explicitly because it's indie nested Navigator
        leading: BackButton(
          onPressed: widget.onCanceled,
        ),
        title: Text(context.strings.termsOfServiceTitle),
      ),
      body: SafeArea(
        child: _getBody(context),
      ),
    );
  }

  Widget _getBody(BuildContext context) {
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
            onPressed: documentLoaded ? _onAccept : null,
            child: Text(context.strings.buttonAgreeLabel),
          ),
        ),
      ],
    );
  }

  void _onAccept() {
    // TODO Get current ToS document version
    const version = 1;

    context.read<ISettings?>()?.acceptedTermsOfServiceVersion.value = version;
    widget.onTermsOfServiceAccepted();
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'OnboardingAcceptTermsOfServiceScreen',
  type: OnboardingAcceptTermsOfServiceScreen,
)
Widget previewOnboardingAcceptTermsOfServiceScreen(BuildContext context) {
  return OnboardingAcceptTermsOfServiceScreen(
    onCanceled: () {
      developer.log("onTermsOfServiceAccepted");
    },
    onTermsOfServiceAccepted: () {
      developer.log("onTermsOfServiceAccepted");
    },
  );
}
