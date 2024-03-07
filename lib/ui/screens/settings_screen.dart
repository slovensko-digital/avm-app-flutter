import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/pdf_signing_option.dart';
import '../../data/settings.dart';
import '../widgets/option_picker.dart';
import '../widgets/preference_tile.dart';

/// App setting screen for editing [Settings].
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Nastavenia"),
      ),
      body: const _SettingsScreenBody(),
    );
  }
}

// TODO Create preview
// Need to pass / provide Settings
class _SettingsScreenBody extends StatelessWidget {
  const _SettingsScreenBody();

  @override
  Widget build(BuildContext context) {
    final settings = context.read<Settings>();

    return ListView(
      primary: true,
      padding: const EdgeInsets.all(16),
      children: [
        StatefulBuilder(
          builder: (context, setState) {
            return PreferenceTile(
              title: "Podpisovanie PDF",
              summary: settings.signingPdfContainer.value.label,
              onPressed: () async {
                final edited = await _editSigningPdfContainerSetting(
                  context,
                  settings.signingPdfContainer,
                );

                if (edited) {
                  setState(() {});
                }
              },
            );
          },
        ),
        const Divider(height: 1),
      ],
    );
  }

  /// Opens the editor for this [setting].
  Future<bool> _editSigningPdfContainerSetting(
    BuildContext context,
    ValueNotifier<PdfSigningOption> setting,
  ) async {
    final result = await showDialog<PdfSigningOption>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Podpisovanie PDF"),
          surfaceTintColor: Theme.of(context).colorScheme.background,
          content: _pdfSigningOptionSelection(
            selectedValue: setting.value,
            onValueSet: (PdfSigningOption value) {
              Navigator.of(context).pop(value);
            },
          ),
        );
      },
    );

    if (result != null) {
      if (context.mounted) {
        setting.value = result;

        return true;
      }
    }

    return false;
  }
}

Widget _pdfSigningOptionSelection({
  required PdfSigningOption? selectedValue,
  required ValueSetter<PdfSigningOption> onValueSet,
}) {
  return SizedBox(
    width: 280,
    height: 200,
    child: OptionPicker(
      values: PdfSigningOption.values,
      selectedValue: selectedValue,
      onValueChanged: onValueSet,
      labelBuilder: (PdfSigningOption value) => Text(value.label),
    ),
  );
}
