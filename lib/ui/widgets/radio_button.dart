import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../app_theme.dart';

/// Wraps [Radio] with custom size.
class RadioButton<T> extends StatelessWidget {
  final T value;
  final bool enabled;

  const RadioButton({
    super.key,
    required this.value,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: kRadioScale,
      child: Radio<T>(
        value: value,
        enabled: enabled,
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'RadioButton',
  type: RadioButton,
)
Widget previewRadioButton(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  int selectedValue = 0;

  return StatefulBuilder(
    builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: RadioGroup<int>(
          groupValue: selectedValue,
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedValue = value);
            }
          },
          child: OverflowBar(
            spacing: 24,
            children: [
              RadioButton(value: 0, enabled: enabled),
              RadioButton(value: 1, enabled: enabled),
              RadioButton(value: 2, enabled: enabled),
            ],
          ),
        ),
      );
    },
  );
}
