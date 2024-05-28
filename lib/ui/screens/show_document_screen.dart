import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../fragment/show_web_page_fragment.dart';
import 'about_screen.dart';
import 'onboarding_accept_document_screen.dart';

/// Screen to display some HTML document using [ShowWebPageFragment].
///
/// See also:
///  - [AboutScreen]
///  - [OnboardingAcceptDocumentScreen]
class ShowDocumentScreen extends StatelessWidget {
  final String title;
  final Uri url;

  const ShowDocumentScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final body = ShowWebPageFragment(
      url: url,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title),
        actions: const [CloseButton()],
      ),
      body: body,
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: '',
  type: ShowDocumentScreen,
)
Widget previewShowDocumentScreen(BuildContext context) {
  final strings = context.strings;
  final title = context.knobs.string(
    label: "Title",
    initialValue: strings.privacyPolicyTitle,
  );
  final url = context.knobs.string(
    label: "URL",
    initialValue: strings.privacyPolicyUrl,
  );

  return ShowDocumentScreen(
    title: title,
    url: Uri.parse(url),
  );
}
