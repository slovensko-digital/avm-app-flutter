import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../app_theme.dart';
import 'loading_indicator.dart';

/// Just placeholder class for widgetbook preview.
abstract class Button {}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'text',
  type: Button,
)
Widget previewTextButton(BuildContext context) {
  final enabled = context.knobs.boolean(label: "Enabled", initialValue: true);
  final text = context.knobs.string(
    label: "Text",
    initialValue: "Button text",
  );

  return Padding(
    padding: kScreenMargin,
    child: TextButton(
      onPressed: (enabled ? () {} : null),
      child: Text(text),
    ),
  );
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'elevated',
  type: Button,
)
Widget previewElevatedButton(BuildContext context) {
  final enabled = context.knobs.boolean(label: "Enabled", initialValue: true);
  final text = context.knobs.string(
    label: "Text",
    initialValue: "Button text",
  );

  return Padding(
    padding: kScreenMargin,
    child: FilledButton(
      onPressed: (enabled ? () {} : null),
      child: Text(text),
    ),
  );
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'filled',
  type: Button,
)
Widget previewFilledButton(BuildContext context) {
  final enabled = context.knobs.boolean(label: "Enabled", initialValue: true);
  final isLoading = context.knobs.boolean(label: "Loading");
  final text = context.knobs.string(
    label: "Text",
    initialValue: "Button text",
  );
  final child = switch (isLoading) {
    false => Text(text),
    true => const LoadingIndicator(),
  };

  return Padding(
    padding: kScreenMargin,
    child: FilledButton(
      onPressed: (enabled ? () {} : null),
      child: child,
    ),
  );
}
