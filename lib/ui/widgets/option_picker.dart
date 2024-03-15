import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../data/pdf_signing_option.dart';
import '../app_theme.dart';

/// Reusable widget to pick single option.
/// Represented as vertical list of [Radio].
class OptionPicker<T> extends StatelessWidget {
  final List<T> values;
  final T? selectedValue;
  final ValueChanged<T> onValueChanged;
  final Widget Function(T item)? labelBuilder;

  const OptionPicker({
    super.key,
    required this.values,
    this.selectedValue,
    required this.onValueChanged,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final labelBuilder = this.labelBuilder ?? _defaultLabelBuilder;

    return ListView.builder(
      itemCount: values.length,
      itemBuilder: (context, index) {
        final value = values[index];
        final label = labelBuilder(value);
        final radio = Transform.scale(
          scale: kRadioScale,
          child: Radio<T>(
            value: value,
            groupValue: selectedValue,
            onChanged: (value) {
              if (value != null) {
                onValueChanged(value);
              }
            },
            activeColor: kRadioActiveColor,
          ),
        );

        return Padding(
          padding: kMaterialListPadding,
          child: Material(
            child: InkWell(
              onTap: () {
                onValueChanged(value);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  radio,
                  const SizedBox(width: 16),
                  label,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _defaultLabelBuilder(T value) {
    final text = (value is Enum ? value.name : value.toString());

    return Expanded(
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'OptionPicker',
  type: OptionPicker,
)
Widget previewOptionPicker(BuildContext context) {
  PdfSigningOption? selectedValue;

  return StatefulBuilder(
    builder: (context, setState) {
      return OptionPicker(
        values: PdfSigningOption.values,
        selectedValue: selectedValue,
        onValueChanged: (value) {
          setState(() => selectedValue = value);
        },
      );
    },
  );
}
