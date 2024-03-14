import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../app_theme.dart';
import 'certificate_picker.dart';

/// Displays two options to select the "signature type" - with or without
/// timestamp.
///
/// See also:
///  - [CertificatePicker]
class SignatureTypePicker extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool> onValueChanged;

  const SignatureTypePicker({
    super.key,
    required this.value,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: true,
      children: [
        _listItem(false),
        const SizedBox(height: 8),
        _listItem(true),
      ],
    );
  }

  Widget _listItem(bool value) {
    return _ListItem(
      value: value,
      selectedValue: this.value,
      onSelected: () {
        onValueChanged(value);
      },
    );
  }
}

/// [SignatureTypePicker] - [ListView] item.
class _ListItem extends StatelessWidget {
  final bool value;
  final bool? selectedValue;
  final VoidCallback onSelected;

  const _ListItem({
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final titleText = switch (value) {
      true => 'Osvedčený podpis',
      false => 'Vlastnoručný podpis',
    };
    final subtitleText = switch (value) {
      true =>
        'Ako keby ste podpis overili u\u{00A0}notára.\nObsahuje časovú pečiatku.',
      false =>
        'Ako keby ste tento dokument podpísali na\u{00A0}papieri.\nBez časovej pečiatky.',
    };

    // NOT using  RadioListTile because need to scale-up and style Radio

    return ListTile(
      onTap: onSelected,
      leading: Transform.scale(
        scale: kRadioScale,
        child: Radio<bool>(
          value: value,
          groupValue: selectedValue,
          onChanged: (final bool? value) {
            if (value != null) {
              if (selectedValue != value) {
                onSelected();
              }
            }
          },
          activeColor: kRadioActiveColor,
        ),
      ),
      title: Text(
        titleText,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitleText),
    );
  }
}

@widgetbook.UseCase(
  path: '[Lists]',
  name: 'SignatureTypePicker',
  type: SignatureTypePicker,
)
Widget previewSignatureTypePicker(BuildContext context) {
  bool? selectedValue;

  return StatefulBuilder(
    builder: (context, setState) {
      return SignatureTypePicker(
        value: selectedValue,
        onValueChanged: (value) {
          setState(() => selectedValue = value);
        },
      );
    },
  );
}
