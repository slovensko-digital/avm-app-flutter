import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../data/pdf_signing_option.dart';
import '../../data/settings.dart';
import '../app_theme.dart';
import '../fragment/show_web_page_fragment.dart';
import '../widgets/option_picker.dart';
import '../widgets/preference_tile.dart';

/// App setting screen for editing [Settings].
///
/// Contains:
///  - [ISettings.signingPdfContainer]
///  - link to show ToS
///  - app version
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Nastavenia"),
      ),
      body: _SettingsScreenBody(
        settings: context.read(),
      ),
    );
  }
}

class _SettingsScreenBody extends StatelessWidget {
  final ISettings settings;

  const _SettingsScreenBody({required this.settings});

  @override
  Widget build(BuildContext context) {
    final settingsChild = _buildSettingsList(context);
    final child = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: settingsChild,
        ),
        TextButton(
          onPressed: () {
            _showAbout(context);
          },
          child: const Text("O aplikácii"),
        ),
      ],
    );

    return Padding(
      padding: kScreenMargin,
      child: child,
    );
  }

  /// Builds [ListView] of settings.
  Widget _buildSettingsList(BuildContext context) {
    return ListView(
      primary: true,
      children: [
        // ISettings.signingPdfContainer
        StatefulBuilder(
          builder: (context, setState) {
            final setting = settings.signingPdfContainer;

            return PreferenceTile(
              title: "Podpisovanie PDF",
              summary: setting.value.label,
              onPressed: () async {
                final edited = await _editSigningPdfContainerSetting(
                  context,
                  setting,
                );

                if (edited) {
                  setState(() {});
                }
              },
            );
          },
        ),
        const Divider(height: 1),

        // Terms of Service
        PreferenceTile(
          title: "Podmienky používania",
          onPressed: () {
            _showTermsOfService(context);
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
      setting.value = result;
    }

    return (result != null);
  }

  /// Shows Terms of Service in dialog.
  Future<void> _showTermsOfService(BuildContext context) {
    final url = Uri.parse("https://slovensko.digital/o-nas/stanovy/");
    final content = SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Podmienky používania"),
          actions: const [
            CloseButton(),
          ],
        ),
        body: ShowWebPageFragment(
          url: url,
        ),
      ),
    );

    // OR showDialog() + Dialog.fullscreen
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, __, ___) {
        return content;
      },
    );
  }

  /// Shows About dialog.
  void _showAbout(BuildContext context) async {
    final pi = await PackageInfo.fromPlatform();
    final versionText = "Verzia: ${pi.version} (${pi.buildNumber})";

    if (context.mounted) {
      showAboutDialog(
        context: context,
        applicationVersion: versionText,
        applicationLegalese: "Nový, lepší a krajší podpisovač v\u{00A0}mobile",
        //applicationLegalese:
        //    "### Typically this is a copyright notice. ###",
      );
    }
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

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'SettingsScreen',
  type: SettingsScreen,
)
Widget previewSettingsScreen(BuildContext context) {
  final settings = _MockSettings();

  return _SettingsScreenBody(
    settings: settings,
  );
}

class _MockSettings implements ISettings {
  @override
  late final ValueNotifier<int?> acceptedTermsOfServiceVersion =
      ValueNotifier(null);

  @override
  late final ValueNotifier<PdfSigningOption> signingPdfContainer =
      ValueNotifier(PdfSigningOption.pades);

  @override
  late final ValueNotifier<Certificate?> signingCertificate =
      ValueNotifier(null);
}
