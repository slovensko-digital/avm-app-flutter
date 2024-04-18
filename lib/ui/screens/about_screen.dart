import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show HookWidget, useFuture, useMemoized;
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../app_theme.dart';
import 'show_terms_of_service_screen.dart';

/// Displays About.
///
/// See also:
///  - [ShowTermsOfServiceScreen]
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
        Text(
          strings.appName,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 16),
        const _AppVersionText(),
        const SizedBox(height: 64),
        Text(strings.eidSDKLicenseText),
        const SizedBox(height: 64),
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

/// Displays app version: "1.0.0(1)".
class _AppVersionText extends HookWidget {
  const _AppVersionText();

  @override
  Widget build(BuildContext context) {
    final future = useMemoized(() => PackageInfo.fromPlatform());
    final pi = useFuture(future).data;
    final appVersion = (pi != null ? "${pi.version}(${pi.buildNumber})" : null);

    return Text(
      appVersion ?? '',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge,
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
