import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../app_theme.dart';
import '../widgets/app_version_text.dart';
import '../widgets/markdown_text.dart';
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

    final child = Column(
      children: [
        Semantics(
          header: true,
          child: Text(
            strings.appName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const SizedBox(height: 16),
        const AppVersionText(),
        const SizedBox(height: 16),
        MarkdownText(strings.aboutAuthorsText),
        const SizedBox(height: 16),
        MarkdownText(strings.eidSDKLicenseText),
        const SizedBox(height: kButtonSpace),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: kScreenMargin,
                child: child,
              ),
            ),
          ),
        );
      },
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
