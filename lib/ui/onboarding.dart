import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/app_bloc.dart';
import '../data/settings.dart';
import '../strings_context.dart';
import 'screens/onboarding_accept_document_screen.dart';
import 'screens/onboarding_finished_screen.dart';
import 'screens/onboarding_select_signing_certificate_screen.dart';

/// Helper for Onboarding flow.
///
/// Reads [Settings].
///
/// Onboarding flow:
///  1. Accept Privacy Policy - [OnboardingAcceptDocumentScreen]
///  2. Accept Terms of Service - [OnboardingAcceptDocumentScreen]
///  3. Select Signing Certificate - [OnboardingSelectSigningCertificateScreen]
///  4. Success - [OnboardingFinishedScreen]
abstract class Onboarding {
  static final ValueNotifier<bool?> _onboardingRequired = ValueNotifier(null);

  /// Indicates whether starting Onboarding is required.
  static ValueListenable<bool?> get onboardingRequired => _onboardingRequired;

  /// Refresh [onboardingRequired] value.
  static void refreshOnboardingRequired(BuildContext context) {
    final settings = context.read<Settings>();
    bool flag;

    if (settings.acceptedPrivacyPolicyVersion.value == null) {
      flag = true;
    } else if (settings.acceptedTermsOfServiceVersion.value == null) {
      flag = true;
    } else {
      flag = false;
    }

    _onboardingRequired.value = flag;
  }

  /// Starts 1st Onboarding screen.
  static Future<dynamic> startOnboarding(BuildContext context) {
    final settings = context.read<Settings>();
    final strings = context.strings;
    final screen = OnboardingAcceptDocumentScreen(
      title: strings.privacyPolicyTitle,
      url: Uri.parse(strings.privacyPolicyUrl),
      step: 1,
      versionSetter: (version) async {
        settings.acceptedPrivacyPolicyVersion.value = version;
      },
      onAccepted: _handlePrivacyPolicyAccepted,
    );

    return _navigateToScreen(context, screen);
  }

  static Future<dynamic> _navigateToScreen(
    BuildContext context,
    Widget screen, [
    bool replace = false,
  ]) {
    final route = MaterialPageRoute(
      settings: RouteSettings(
        name: screen.runtimeType.toString(),
      ),
      builder: (_) => screen,
    );
    final navigator = Navigator.of(context);

    return replace ? navigator.pushReplacement(route) : navigator.push(route);
  }

  static void _handlePrivacyPolicyAccepted(BuildContext context) {
    final settings = context.read<Settings>();
    final strings = context.strings;
    final screen = OnboardingAcceptDocumentScreen(
      title: strings.termsOfServiceTitle,
      url: Uri.parse(strings.termsOfServiceUrl),
      step: 2,
      versionSetter: (version) async {
        settings.acceptedTermsOfServiceVersion.value = version;
      },
      onAccepted: _handleTermsOfServiceAccepted,
    );

    _navigateToScreen(context, screen, true);
  }

  static void _handleTermsOfServiceAccepted(BuildContext context) {
    final settings = context.read<Settings>();
    final hasSigningCertificate = settings.signingCertificate.value != null;
    final Widget screen;

    if (!hasSigningCertificate) {
      screen = const OnboardingSelectSigningCertificateScreen(
        onCertificateSelected: _handleCertificateSelectionCompleted,
        onSkipRequested: _handleCertificateSelectionCompleted,
      );
    } else {
      screen = const OnboardingFinishedScreen(
        onStartRequested: _handleStartRequested,
      );
    }

    _navigateToScreen(context, screen, true);
  }

  static void _handleCertificateSelectionCompleted(BuildContext context) {
    const screen = OnboardingFinishedScreen(
      onStartRequested: _handleStartRequested,
    );

    _navigateToScreen(context, screen, true);
  }

  static void _handleStartRequested(BuildContext context) {
    // TODO Make sure this is always in sync by listening to both values; use TransformValueListenable
    refreshOnboardingRequired(context);

    // Notify parent
    context.read<AppBloc>().add(const RequestOpenFileEvent());

    // Navigate to root
    Navigator.of(context).popUntil((route) {
      // Remove until MainScreen
      return (route.settings.name == '/');
    });
  }
}
