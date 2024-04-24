import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../widgets/app_version_text.dart';
import 'about_screen.dart';
import 'settings_screen.dart';
import 'show_terms_of_service_screen.dart';

/// Screen that displays "main menu" with items:
///  - link to show [SettingsScreen]
///  - link to show [ShowTermsOfServiceScreen]
///  - link to show [AboutScreen]
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              "Menu",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.15,
              ),
            ),
          ),
          _MenuItem(
            title: strings.settingsTitle,
            onPressed: () {
              _showSettings(context);
            },
          ),
          // const _MenuItem(
          //   title: "Podpísať vzdialený dokument",
          //   onPressed: null,
          // ),
          _MenuItem(
            title: strings.termsOfServiceTitle,
            onPressed: () {
              _showTermsOfService(context);
            },
          ),
          _MenuItem(
            title: strings.aboutTitle,
            onPressed: () {
              _showAbout(context);
            },
          ),
          const Spacer(flex: 1),
          const AppVersionText(
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ],
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

  static Future<void> _showTermsOfService(BuildContext context) {
    const screen = ShowTermsOfServiceScreen();

    return _openScreen(context, screen);
  }

  static Future<void> _showAbout(BuildContext context) {
    const screen = AboutScreen();

    return _openScreen(context, screen);
  }

  static Future<void> _openScreen(BuildContext context, Widget screen) {
    final route = MaterialPageRoute(builder: (_) => screen);

    return Navigator.of(context).pushReplacement(route);
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const _MenuItem({required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final text = Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: text,
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
  return const MainMenuScreen();
}
