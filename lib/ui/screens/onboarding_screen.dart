import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/settings.dart';
import 'onboarding_accept_terms_of_service_screen.dart';
import 'onboarding_finished_screen.dart';
import 'onboarding_select_signing_certificate_screen.dart';

/// Screen for whole onboarding flow.
/// Uses its own [Navigator].
///
/// Flow based on steps from [_OnboardingStep] values:
///  1. Accept Terms of Service - [OnboardingAcceptTermsOfServiceScreen]
///  2. Select Signing Certificate - [OnboardingSelectSigningCertificateScreen]
///  3. Success - [OnboardingFinishedScreen]
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Need child Navigator so we can navigate between steps
    return Navigator(
      key: navigatorKey,
      initialRoute: _OnboardingStep.values.first.name,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final route = settings.name!;
    final step = _OnboardingStep.values.byName(route);
    final Widget child = switch (step) {
      _OnboardingStep.acceptTermsOfService =>
        OnboardingAcceptTermsOfServiceScreen(
          onCanceled: () {
            Navigator.of(context).maybePop();
          },
          onTermsOfServiceAccepted: _handleTermsOfServiceAccepted,
        ),
      _OnboardingStep.selectSigningCertificate =>
        OnboardingSelectSigningCertificateScreen(
          onCertificateSelected: _handleCertificateSelected,
          onSkipRequested: _handleCertificateSelectionSkipped,
        ),
      _OnboardingStep.showSummary => OnboardingFinishedScreen(
          onStartRequested: _handleStartRequested,
        ),
    };

    return MaterialPageRoute(
      builder: (context) => child,
    );
  }

  void _navigateToStep(_OnboardingStep step) {
    navigatorKey.currentState?.pushNamed(step.name);
  }

  void _handleTermsOfServiceAccepted() {
    final settings = context.read<ISettings>();
    final hasSigningCertificate = settings.signingCertificate.value != null;
    final nextStep = hasSigningCertificate
        ? _OnboardingStep.showSummary
        : _OnboardingStep.selectSigningCertificate;

    _navigateToStep(nextStep);
  }

  void _handleCertificateSelectionSkipped() {
    _navigateToStep(_OnboardingStep.showSummary);
  }

  void _handleCertificateSelected() {
    _navigateToStep(_OnboardingStep.showSummary);
  }

  void _handleStartRequested() {
    Navigator.of(context).popUntil((route) {
      // Remove until MainScreen
      if (route.settings.name == '/') {
        // This "result" will be read
        (route.settings.arguments as Map)["result"] = true;
        return true;
      }

      return false;
    });
  }
}

/// Step for [OnboardingScreen].
enum _OnboardingStep {
  acceptTermsOfService,
  selectSigningCertificate,
  showSummary,
}
