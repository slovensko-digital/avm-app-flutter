import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_service.dart';
import '../data/settings.dart';
import '../di.dart';
import 'onboarding.dart';
import 'screens/qr_code_scanner_screen.dart';
import 'screens/start_remote_document_signing_screen.dart';

/// Helper for "Remote Document Signing" flow.
///
/// Reads and sets [Settings.remoteDocumentSigningOnboardingPassed].
///
/// And then displays:
///  1. When `false` - [StartRemoteDocumentSigningScreen]
///  2. When `true` - [QRCodeScannerScreen] directly
///
/// See also:
///  - [Onboarding]
abstract class RemoteDocumentSigning {
  /// Starts 1st screen in this flow.
  ///
  /// When [forceReplace] is `true`, then [Navigator.pushReplacement] is used.
  static Future<void> startRemoteDocumentSigning(
    BuildContext context, [
    bool forceReplace = false,
  ]) async {
    final settings = context.read<Settings>();
    final onboardingPassed =
        settings.remoteDocumentSigningOnboardingPassed.value;
    Widget screen = onboardingPassed
        ? const QRCodeScannerScreen()
        : const StartRemoteDocumentSigningScreen();
    final result = await _navigateToScreen(context, screen, forceReplace);

    if (result is String) {
      getIt.get<AppService>().newIncomingUri(result);
    }
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
}
