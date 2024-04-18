import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../fragment/show_web_page_fragment.dart';
import 'about_screen.dart';

/// Screen to display only Terms of Service (ToS).
///
/// See also:
///  - [AboutScreen]
class ShowTermsOfServiceScreen extends StatelessWidget {
  static final url = Uri.parse("https://slovensko.digital/o-nas/stanovy/");

  const ShowTermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final body = ShowWebPageFragment(
      url: url,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(context.strings.termsOfServiceTitle),
        actions: const [CloseButton()],
      ),
      body: body,
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'ShowTermsOfServiceScreen',
  type: ShowTermsOfServiceScreen,
)
Widget previewShowTermsOfServiceScreen(BuildContext context) {
  return const ShowTermsOfServiceScreen();
}
