import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Displays text formatted in Markdown.
///
/// By default, links are open in external application.
class MarkdownText extends StatelessWidget {
  final String data;
  final MarkdownTapLinkCallback onLinkTap;

  const MarkdownText(
    this.data, {
    super.key,
    this.onLinkTap = _defaultOnLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final styleSheet = MarkdownStyleSheet(
      a: TextStyle(
        color: colors.primary,
        fontWeight: FontWeight.bold,
        //decoration: TextDecoration.underline, // UGLY :/
        decorationColor: colors.primary,
      ),
    );

    return MarkdownBody(
      data: data,
      styleSheet: styleSheet,
      onTapLink: onLinkTap,
    );
  }

  static void _defaultOnLinkTap(String text, String? href, String title) {
    if (href != null) {
      launchUrlString(href, mode: LaunchMode.externalApplication);
    }
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: '',
  type: MarkdownText,
)
Widget previewMarkdownText(BuildContext context) {
  final data = context.knobs.string(
    label: 'Data',
    initialValue: """
# Supported Markdown

## Unordered List + Text formatting

- This is normal text
- **This is bold text**
- _This is italic text_
- ~~This is striked text~~
- [Link text](https://slovensko.digital)

## Ordered List

1. Lorem ipsum dolor sit amet
2. Consectetur adipiscing elit
3. Integer molestie lorem at massa
     """,
    maxLines: 5,
  );

  return MarkdownText(
    data,
    onLinkTap: (String text, String? href, String title) {
      developer.log("On link tap: $text -> $href");
    },
  );
}
