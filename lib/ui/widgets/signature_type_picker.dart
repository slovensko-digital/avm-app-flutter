import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

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

// https://www.figma.com/file/9i8kwShc6o8Urp2lYoPg6M/Autogram-v-mobile-(WIP)?type=design&node-id=74-818&mode=design&t=DIMIlOrnvS7QK01m-0
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
    final title = switch (value) {
      true => 'Osvedčený podpis',
      false => 'Vlastnoručný podpis',
    };
    final subtitle = switch (value) {
      true =>
        'Ako keby ste podpis overili u\u{00A0}notára.\nObsahuje časovú pečiatku.',
      false =>
        'Ako keby ste tento dokument podpísali na\u{00A0}papieri.\nBez časovej pečiatky.',
    };

    return RadioListTile(
      value: value,
      groupValue: selectedValue,
      onChanged: (final bool? value) {
        if (value != null) {
          if (selectedValue != value) {
            onSelected();
          }
        }
      },
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
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
