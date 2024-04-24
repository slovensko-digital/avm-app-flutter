import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Single preference M3 Tile with [title] and optional [summary] below.
class PreferenceTile extends StatelessWidget {
  final String title;
  final String? summary;
  final VoidCallback? onPressed;

  const PreferenceTile({
    super.key,
    required this.title,
    this.summary,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const titleTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    final subtitle = summary != null ? Text(summary ?? '') : null;
    final trailing =
        onPressed != null ? const Icon(Icons.arrow_forward_ios_outlined) : null;

    return Material(
      child: ListTile(
        onTap: onPressed,
        title: Text(title, style: titleTextStyle),
        subtitle: subtitle,
        trailing: trailing,
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'PreferenceTile',
  type: PreferenceTile,
)
Widget previewPreferenceTile(BuildContext context) {
  final title = context.knobs.string(
    label: "Title",
    initialValue: "Preference title",
  );
  final summary = context.knobs.stringOrNull(
    label: "Summary",
    initialValue: "Preference summary",
  );
  final enabled = context.knobs.boolean(
    label: "Enabled",
    initialValue: true,
  );

  return PreferenceTile(
    title: title,
    summary: summary,
    onPressed: (enabled ? () {} : null),
  );
}
