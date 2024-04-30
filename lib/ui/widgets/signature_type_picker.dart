import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../data/signature_type.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import 'certificate_picker.dart';

/// Displays two options to select the [SignatureType] options.
///
/// See also:
///  - [CertificatePicker]
class SignatureTypePicker extends StatelessWidget {
  final SignatureType? value;
  final ValueChanged<SignatureType> onValueChanged;

  const SignatureTypePicker({
    super.key,
    required this.value,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        _listItem(SignatureType.withTimestamp),
        const SizedBox(height: kButtonSpace),
        _listItem(SignatureType.withoutTimestamp),
      ],
    );
  }

  Widget _listItem(SignatureType value) {
    return _ListItem(
      value: value, // value from param
      selectedValue: this.value, // value from Widget
      onSelected: () {
        onValueChanged(value);
      },
    );
  }
}

/// [SignatureTypePicker] - [ListView] item.
class _ListItem extends StatelessWidget {
  final SignatureType value;
  final SignatureType? selectedValue;
  final VoidCallback onSelected;

  const _ListItem({
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final titleText = strings.signatureTypeValueTitle(value.name);
    final subtitleText = strings.signatureTypeValueSubtitle(value.name);

    // NOT using RadioListTile because need to scale-up and style Radio

    return ListTile(
      onTap: onSelected,
      leading: Transform.scale(
        scale: kRadioScale,
        child: Radio<SignatureType>(
          value: value,
          groupValue: selectedValue,
          onChanged: (final SignatureType? value) {
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
  SignatureType? selectedValue;

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
