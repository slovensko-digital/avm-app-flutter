import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../app_theme.dart';
import 'certificate_picker.dart';

/// Displays two options to select the "signature type" - with or without
/// timestamp.
///
/// See also:
///  - [CertificatePicker]
class SignatureTypePicker extends StatelessWidget {
  final bool? withTimestamp;
  final ValueChanged<bool> onWithTimestampChanged;

  const SignatureTypePicker({
    super.key,
    required this.withTimestamp,
    required this.onWithTimestampChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        _listItem(false),
        const SizedBox(height: 8),
        _listItem(true),
      ],
    );
  }

  Widget _listItem(bool withTimestamp) {
    return _ListItem(
      withTimestamp: withTimestamp, // value from param
      selectedValue: this.withTimestamp, // value from Widget
      onSelected: () {
        onWithTimestampChanged(withTimestamp);
      },
    );
  }
}

/// [SignatureTypePicker] - [ListView] item.
class _ListItem extends StatelessWidget {
  final bool withTimestamp;
  final bool? selectedValue;
  final VoidCallback onSelected;

  const _ListItem({
    required this.withTimestamp,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final titleText = switch (withTimestamp) {
      true => strings.signatureTypeWithTimestampTitle,
      false => strings.signatureTypeWithoutTimestampTitle,
    };
    final subtitleText = switch (withTimestamp) {
      true => strings.signatureTypeWithTimestampSubtitle,
      false => strings.signatureTypeWithoutTimestampSubtitle,
    };

    // NOT using RadioListTile because need to scale-up and style Radio

    return ListTile(
      onTap: onSelected,
      leading: Transform.scale(
        scale: kRadioScale,
        child: Radio<bool>(
          value: withTimestamp,
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
        withTimestamp: selectedValue,
        onWithTimestampChanged: (value) {
          setState(() => selectedValue = value);
        },
      );
    },
  );
}
