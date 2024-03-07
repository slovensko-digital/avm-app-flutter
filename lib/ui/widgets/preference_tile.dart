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
    return ListTile(
      onTap: onPressed,
      title: Text(title),
      subtitle: Text(summary ?? ''),
      trailing: const Icon(Icons.arrow_forward_ios_outlined),
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'PreferenceTile',
  type: PreferenceTile,
)
Widget previewPreferenceTile(BuildContext context) {
  final enabled = context.knobs.boolean(
    label: "Enabled",
    initialValue: true,
  );

  return PreferenceTile(
    title: "Preference title",
    summary: "Preference summary",
    onPressed: (enabled ? () {} : null),
  );
}
