import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Chip widget with [label] text inside.
/// Has [foreground], [background] and [border] colors, and optional
/// [leading] widget.
class Chip extends StatelessWidget {
  final Widget? leading;
  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  const Chip({
    super.key,
    this.leading,
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  @override
  material.Widget build(material.BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          if (leading != null) leading!,
          Text(label, style: TextStyle(color: foreground)),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: '',
  type: Chip,
)
Widget previewChip(BuildContext context) {
  var label = context.knobs.string(
    label: 'Label',
    initialValue: 'Chip!',
  );
  var foreground = context.knobs.color(
    label: 'Foreground',
    initialValue: material.Colors.black,
  );
  var background = context.knobs.color(
    label: 'Background',
    initialValue: material.Colors.white,
  );
  var border = context.knobs.color(
    label: 'Border',
    initialValue: material.Colors.black,
  );
  var icon = context.knobs.listOrNull(
    label: 'Icon',
    options: ['ok', 'warning', 'error'],
  );

  return Chip(
    label: label,
    foreground: foreground,
    background: background,
    border: border,
    leading: (icon != null
        ? Icon(switch (icon) {
            'ok' => material.Icons.check,
            'warning' => material.Icons.warning_amber_outlined,
            'error' => material.Icons.error_outline,
            _ => material.Icons.question_mark,
          })
        : null),
  );
}
