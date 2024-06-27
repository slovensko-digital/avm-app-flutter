import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../app_theme.dart';
import '../widgets/app_version_text.dart';
import 'show_document_screen.dart';

/// Displays About appliaction:
///  - headline, version
///  - authors, eID mSDK info
///  - link to [showLicensePage]
///
/// See also:
///  - [ShowDocumentScreen]
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(context.strings.aboutTitle),
        actions: const [CloseButton()],
      ),
      body: const _Body(),
    );
  }
}

/// [AboutScreen] body.
class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    void onLinkTap(String text, String? href, String title) {
      if (href != null) {
        launchUrlString(href, mode: LaunchMode.externalApplication);
      }
    }

    // TODO Fix vertical bottom overflow
    final child = Column(
      children: [
        Text(
          strings.appName,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 16),
        const AppVersionText(),
        const SizedBox(height: 16),
        // TODO Extract as MarkdownText(String) with preset params
        MarkdownBody(
          data: strings.aboutAuthorsText,
          // TODO Add stylesheet - link color and bold
          onTapLink: onLinkTap,
        ),
        const SizedBox(height: 16),
        MarkdownBody(
          data: strings.eidSDKLicenseText,
          // TODO Add stylesheet - link color and bold
          onTapLink: onLinkTap,
        ),
        const Spacer(),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: () => _showLicenses(context),
          child: Text(strings.thirdPartyLicensesLabel),
        ),
      ],
    );

    return Padding(
      padding: kScreenMargin,
      child: child,
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: context.strings.appName,
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'AboutScreen',
  type: AboutScreen,
)
Widget previewAboutScreen(BuildContext context) {
  return const AboutScreen();
}
