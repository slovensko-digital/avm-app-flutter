import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../remote_document_signing.dart';
import '../widgets/app_version_text.dart';
import 'about_screen.dart';
import 'settings_screen.dart';
import 'show_document_screen.dart';
import 'start_remote_document_signing_screen.dart';

/// Screen that displays "main menu" with items:
///  - link to show [SettingsScreen]
///  - link to show [StartRemoteDocumentSigningScreen]
///  - link to show Privacy Policy or Terms of Service in [ShowDocumentScreen]
///  - link to show [AboutScreen]
class MainMenuScreen extends StatelessWidget {
  final void Function(BuildContext context) onShowSettingsPressed;
  final void Function(BuildContext context) onSignRemoteDocumentPressed;
  final void Function(BuildContext context) onShowPrivacyPolicyPressed;
  final void Function(BuildContext context) onShowTermsOfServicePressed;
  final void Function(BuildContext context) onShowAboutPressed;

  /// [MainMenuScreen] constructor with params for preview.
  const MainMenuScreen._({
    super.key,
    required this.onShowSettingsPressed,
    required this.onSignRemoteDocumentPressed,
    required this.onShowPrivacyPolicyPressed,
    required this.onShowTermsOfServicePressed,
    required this.onShowAboutPressed,
  });

  /// Creates new [MainMenuScreen] with default handlers.
  const MainMenuScreen.create({Key? key})
      : this._(
          key: key,
          onShowSettingsPressed: _showSettings,
          onSignRemoteDocumentPressed: _showSignRemoteDocument,
          onShowPrivacyPolicyPressed: _showPrivacyPolicy,
          onShowTermsOfServicePressed: _showTermsOfService,
          onShowAboutPressed: _showAbout,
        );

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final children = [
      const Spacer(flex: 1),
      Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 20),
        child: Semantics(
          header: true,
          child: Text(
            strings.menuTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.15,
            ),
          ),
        ),
      ),
      _MenuItem(
        title: strings.settingsTitle,
        onPressed: () => onShowSettingsPressed(context),
      ),
      _MenuItem(
        title: strings.signRemoteDocumentTitle,
        onPressed: () => onSignRemoteDocumentPressed(context),
      ),
      _MenuItem(
        title: strings.privacyPolicyTitle,
        onPressed: () => onShowPrivacyPolicyPressed(context),
      ),
      _MenuItem(
        title: strings.termsOfServiceTitle,
        onPressed: () => onShowTermsOfServicePressed(context),
      ),
      _MenuItem(
        title: strings.aboutTitle,
        onPressed: () => onShowAboutPressed(context),
      ),
      const Spacer(flex: 1),
      const AppVersionText(
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
    ];

    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: const [CloseButton()],
      ),
      body: SafeArea(child: body),
    );
  }

  static Future<void> _showSettings(BuildContext context) {
    const screen = SettingsScreen();

    return _openScreen(context, screen);
  }

  static Future<void> _showSignRemoteDocument(BuildContext context) {
    // forceReplace=true so it's same as in _openScreen
    return RemoteDocumentSigning.startRemoteDocumentSigning(context, true);
  }

  static Future<void> _showPrivacyPolicy(BuildContext context) {
    final strings = context.strings;
    final screen = ShowDocumentScreen(
      title: strings.privacyPolicyTitle,
      url: Uri.parse(strings.privacyPolicyUrl),
    );

    return _openScreen(context, screen);
  }

  static Future<void> _showTermsOfService(BuildContext context) {
    final strings = context.strings;
    final screen = ShowDocumentScreen(
      title: strings.termsOfServiceTitle,
      url: Uri.parse(strings.termsOfServiceUrl),
    );

    return _openScreen(context, screen);
  }

  static Future<void> _showAbout(BuildContext context) {
    const screen = AboutScreen();

    return _openScreen(context, screen);
  }

  static Future<void> _openScreen(BuildContext context, Widget screen) {
    final route = MaterialPageRoute(
      settings: RouteSettings(
        name: screen.runtimeType.toString(),
      ),
      builder: (_) => screen,
    );

    return Navigator.of(context).pushReplacement(route);
  }
}

/// Single clickable menu item.
class _MenuItem extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const _MenuItem({required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: '',
  type: MainMenuScreen,
)
Widget previewMainMenuScreen(BuildContext context) {
  return MainMenuScreen._(
    onShowSettingsPressed: (_) => developer.log("Show Settings"),
    onSignRemoteDocumentPressed: (_) => developer.log("Sign Remote Document"),
    onShowPrivacyPolicyPressed: (_) => developer.log("Show Privacy Policy"),
    onShowTermsOfServicePressed: (_) => developer.log("Show Terms of Service"),
    onShowAboutPressed: (_) => developer.log("Show About"),
  );
}
