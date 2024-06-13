import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../data/signature_type.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import 'certificate_picker.dart';

/// Displays two options to select the [SignatureType] options; either
/// [SignatureType.withTimestamp] or [SignatureType.withoutTimestamp].
///
/// When [canChange] is `false`, value selection by user is disabled.
///
/// See also:
///  - [CertificatePicker]
class SignatureTypePicker extends StatelessWidget {
  final SignatureType? value;
  final bool canChange;
  final ValueChanged<SignatureType> onValueChanged;

  const SignatureTypePicker({
    super.key,
    required this.value,
    this.canChange = true,
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
      canSelect: canChange,
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
  final bool canSelect;
  final SignatureType? selectedValue;
  final VoidCallback onSelected;

  const _ListItem({
    required this.value,
    required this.canSelect,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final titleText = strings.signatureTypeValueTitle(value.name);
    final subtitleText = strings.signatureTypeValueSubtitle(value.name);

    final enabled = (canSelect || value == selectedValue);
    final radio = Radio<SignatureType>(
      value: value,
      groupValue: selectedValue,
      onChanged: enabled
          ? (final SignatureType? value) {
              if (value != null) {
                if (selectedValue != value) {
                  onSelected();
                }
              }
            }
          : null,
      activeColor: kRadioActiveColor,
    );

    // NOT using RadioListTile because need to scale-up and style Radio
    return ListTile(
      onTap: (canSelect ? onSelected : null),
      enabled: enabled,
      leading: Transform.scale(
        scale: kRadioScale,
        child: radio,
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
  name: '',
  type: SignatureTypePicker,
)
Widget previewSignatureTypePicker(BuildContext context) {
  final bool canChange = context.knobs.boolean(
    label: "Can change",
    initialValue: true,
  );
  SignatureType? selectedValue = context.knobs.listOrNull(
    label: "Signature type",
    options: [SignatureType.withTimestamp, SignatureType.withoutTimestamp],
  );

  return StatefulBuilder(
    builder: (context, setState) {
      return SignatureTypePicker(
        value: selectedValue,
        canChange: canChange,
        onValueChanged: (value) {
          setState(() => selectedValue = value);
        },
      );
    },
  );
}
