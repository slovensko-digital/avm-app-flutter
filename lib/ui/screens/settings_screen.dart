import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../certificate_extensions.dart';
import '../../data/pdf_signing_option.dart';
import '../../data/settings.dart' show ISettings;
import '../../data/signature_type.dart';
import '../../oids.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import '../widgets/option_picker.dart';
import '../widgets/preference_tile.dart';
import 'paired_device_list_screen.dart';

/// App setting screen for editing [ISettings].
///
/// Contains:
///  - editor for [ISettings.signingPdfContainer]
///  - editor for [ISettings.signingCertificate]
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(context.strings.settingsTitle),
        actions: const [CloseButton()],
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
        if (kDebugMode) const SizedBox(height: kButtonSpace),
        if (kDebugMode)
          TextButton.icon(
            style: TextButton.styleFrom(
              minimumSize: kPrimaryButtonMinimumSize,
            ),
            onPressed: () async {
              await settings.clear();
              if (context.mounted) {
                await Navigator.of(context).maybePop();
              }
            },
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text("RESET"),
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
    final strings = context.strings;

    // ISettings.signingPdfContainer
    final signingPdfContainerSetting = _ValueListenableBoundTile(
      setting: settings.signingPdfContainer,
      title: strings.signingPdfContainerTitle,
      summaryGetter: (value) => value.label,
      onEditItemRequested: (context, setting) {
        return _editSigningPdfContainerSetting(context, setting);
      },
    );

    // ISettings.signingCertificate
    final signingCertificate = PreferenceTile(
      title: strings.signingCertificateTitle,
      summary: () {
        final value = settings.signingCertificate.value;
        if (value == null) return null;

        final cert = value.tbsCertificate;

        return [
          cert.subject[X500Oids.cn],
          cert.subject[X500Oids.ln],
          cert.subject[X500Oids.c],
        ].whereType<String>().join(", ");
      }(),
      onPressed: null,
    );

    final signatureType = PreferenceTile(
      title: strings.signatureTypeTitle,
      summary: strings.signatureTypeSummary(""),
      onPressed: null,
    );

    final pairedDevices = PreferenceTile(
      title: strings.pairedDevicesTitle,
      summary: strings.pairedDevicesSummary(0),
      onPressed: () {
        _showPairedDevicesScreen(context);
      },
    );

    const divider = Divider(height: 1);

    return ListView(
      primary: true,
      children: [
        signingPdfContainerSetting,
        divider,
        signingCertificate,
        divider,
        signatureType,
        divider,
        pairedDevices,
        divider,
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
        var selectedValue = setting.value;

        return AlertDialog(
          title: Text(context.strings.signingPdfContainerTitle),
          content: StatefulBuilder(
            builder: (context, setState) {
              return _pdfSigningOptionSelection(
                selectedValue: selectedValue,
                onValueSet: (PdfSigningOption value) {
                  setState(() {
                    selectedValue = value;
                  });

                  // Delay closing this modal so user have chance to see
                  // newly selected option
                  Future.delayed(const Duration(milliseconds: 150), () {
                    Navigator.of(context).pop(value);
                  });
                },
              );
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

  Future<bool> _editSigningCertificateSetting(
    BuildContext context,
    ValueNotifier<Certificate?> setting,
  ) {
    // TODO Impl. Certificate picker in separate screen
    // See: OnboardingSelectSigningCertificateScreen
    return Future.value(false);
  }

  Future<void> _showPairedDevicesScreen(BuildContext context) {
    const screen = PairedDeviceListScreen();
    final route = MaterialPageRoute(builder: (_) => screen);

    return Navigator.of(context).push(route);
  }
}

/// [PreferenceTile] with [title] and `summary` from [summaryGetter].
class _ValueListenableBoundTile<T> extends StatelessWidget {
  final ValueNotifier<T> setting;
  final String title;
  final String? Function(T value) summaryGetter;
  final Future<void> Function(BuildContext context, ValueNotifier<T> setting)
      onEditItemRequested;

  const _ValueListenableBoundTile({
    super.key,
    required this.setting,
    required this.title,
    required this.summaryGetter,
    required this.onEditItemRequested,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: setting,
      builder: (context, value, _) {
        final summary = summaryGetter(setting.value);

        return PreferenceTile(
          title: title,
          summary: summary,
          onPressed: () {
            onEditItemRequested(context, setting);
          },
        );
      },
    );
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

/// Mock [ISettings] impl. for preview.
class _MockSettings implements ISettings {
  @override
  late final ValueNotifier<int?> acceptedTermsOfServiceVersion =
      ValueNotifier(null);

  @override
  late final ValueNotifier<PdfSigningOption> signingPdfContainer =
      ValueNotifier(PdfSigningOption.pades);

  @override
  late final ValueNotifier<SignatureType?> signatureType = ValueNotifier(null);

  @override
  late final ValueNotifier<Certificate?> signingCertificate =
      ValueNotifier(null);

  @override
  Future<bool> clear() {
    final props = <ValueNotifier>[
      acceptedTermsOfServiceVersion,
      signingPdfContainer,
      signatureType,
      signingCertificate,
    ];

    for (final prop in props) {
      prop.value = null;
    }

    return Future.value(true);
  }
}
