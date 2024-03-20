import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'onboarding_accept_terms_of_service_screen.dart';
import 'onboarding_finished_screen.dart';

/// Screen for whole onboarding flow.
///
/// Flow based on steps from [OnboardingStep] :
///  - Accept Terms of Service - [OnboardingAcceptTermsOfServiceScreen]
///  - Select Signing Certificate - ...
///  - Success - [OnboardingFinishedScreen]
class OnboardingScreen extends StatefulWidget {
  // TODO Add all params here, so it can be properly mocked
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  OnboardingStep step = OnboardingStep.acceptTermsOfService;

  @override
  Widget build(BuildContext context) {
    // Need child Navigator so we can navigate between steps
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    // TODO Impl. switch based on current step

    return MaterialPageRoute(
      builder: (context) {
        return OnboardingAcceptTermsOfServiceScreen(
          onTermsOfServiceAccepted: () {
            // TODO Save terms + navigate next
          },
        );
      },
    );
  }
}

/// Step for [OnboardingScreen].
enum OnboardingStep {
  acceptTermsOfService,
  selectSigningCertificate,
  showSummary,
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'OnboardingScreen',
  type: OnboardingScreen,
)
Widget previewOnboardingScreen(BuildContext context) {
  return const OnboardingScreen();
}
