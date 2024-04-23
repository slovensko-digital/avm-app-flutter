import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../data/pdf_signing_option.dart';
import '../../data/settings.dart' show ISettings;
import '../../strings_context.dart';
import '../app_theme.dart';
import '../widgets/option_picker.dart';
import '../widgets/preference_tile.dart';
import 'about_screen.dart';
import 'show_terms_of_service_screen.dart';

/// App setting screen for editing [ISettings].
///
/// Contains:
///  - [ISettings.signingPdfContainer]
///  - link to display [ShowTermsOfServiceScreen]
///  - link to display [AboutScreen]
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(context.strings.settingsTitle),
      ),
      body: SafeArea(
        child: _Body(
          settings: context.read(),
        ),
      ),
    );
  }
}

/// [SettingsScreen] body.
class _Body extends StatelessWidget {
  final ISettings settings;

  const _Body({required this.settings});

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
          style: TextButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: () {
            _showInDialog(context, const AboutScreen());
          },
          child: Text(context.strings.aboutLabel),
        ),
        if (kDebugMode) const SizedBox(height: kButtonSpace),
        if (kDebugMode)
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: kPrimaryButtonMinimumSize,
            ),
            onPressed: () async {
              await settings.clear();
              if (context.mounted) {
                await Navigator.of(context).maybePop();
              }
            },
            child: const Text("RESET"),
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
              title: context.strings.signingPdfContainerTitle,
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
          title: context.strings.termsOfServiceTitle,
          onPressed: () {
            _showInDialog(context, const ShowTermsOfServiceScreen());
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
          title: Text(context.strings.signingPdfContainerTitle),
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

  /// Shows [child] in full screen dialog.
  Future<dynamic> _showInDialog(BuildContext context, Widget child) {
    final route = MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => child,
    );

    return Navigator.of(context).push(route);
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

  return _Body(
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

  @override
  Future<bool> clear() {
    final props = <ValueNotifier>[
      acceptedTermsOfServiceVersion,
      signingPdfContainer,
      signingCertificate,
    ];

    for (final prop in props) {
      prop.value = null;
    }

    return Future.value(true);
  }
}
