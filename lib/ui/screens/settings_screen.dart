import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../certificate_extensions.dart';
import '../../data/pdf_signing_option.dart';
import '../../data/settings.dart';
import '../../data/signature_type.dart';
import '../../oids.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import '../onboarding.dart';
import '../widgets/option_picker.dart';
import '../widgets/preference_tile.dart';
import 'paired_device_list_screen.dart';

/// App setting screen for editing [Settings].
///
/// Contains:
///  - editor for [Settings.signingPdfContainer]
///  - display for [Settings.signingCertificate]
///  - editor for [Settings.signatureType]
///  - navigate to [PairedDeviceListScreen]
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
  final Settings settings;

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
                Onboarding.refreshOnboardingRequired(context);
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

    // Settings.signingPdfContainer
    final signingPdfContainerSetting =
        _ValueListenableBoundTile<PdfSigningOption>(
      setting: settings.signingPdfContainer,
      values: PdfSigningOption.values,
      title: strings.signingPdfContainerTitle,
      summaryGetter: (value) => value.label,
    );

    // Settings.signingCertificate
    final signingCertificate = PreferenceTile(
      title: strings.signingCertificateTitle,
      summary: () {
        final value = settings.signingCertificate.value;
        if (value == null) return null;

        final cert = value.tbsCertificate;

        return cert.subject[X500Oids.cn];
      }(),
      onPressed: null,
    );

    final signatureType = _ValueListenableBoundTile<SignatureType>(
      setting: settings.signatureType,
      values: const [
        SignatureType.unset,
        SignatureType.withTimestamp,
        SignatureType.withoutTimestamp,
      ],
      title: strings.signatureTypeTitle,
      summaryGetter: (value) => strings.signatureTypeSummary(value.name),
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
        // pairedDevices,  TODO: uncomment when pairing works
        // divider,
      ],
    );
  }

  // ignore: unused_element
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
/// Displays [OptionPicker] in [AlertDialog] on pressed.
class _ValueListenableBoundTile<T> extends StatelessWidget {
  final ValueNotifier<T> setting;
  final List<T> values;
  final String title;
  final String? Function(T value) summaryGetter;

  const _ValueListenableBoundTile({
    super.key,
    required this.setting,
    required this.values,
    required this.title,
    required this.summaryGetter,
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
            _onEditItemRequested(context, value);
          },
        );
      },
    );
  }

  Future<void> _onEditItemRequested(BuildContext context, T value) async {
    final result = await showDialog<T>(
      context: context,
      routeSettings: RouteSettings(
        name: "Edit${T}Dialog",
      ),
      builder: (context) {
        var selectedValue = setting.value;

        final content = StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 280,
              height: 200,
              child: OptionPicker<T>(
                values: values,
                selectedValue: selectedValue,
                onValueChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedValue = value;
                    });

                    // Delay closing this modal so user have chance to see
                    // newly selected option
                    Future.delayed(const Duration(milliseconds: 150), () {
                      Navigator.of(context).pop(value);
                    });
                  }
                },
                labelBuilder: (T value) => Text(
                  summaryGetter(value) ?? '',
                  maxLines: 2,
                ),
              ),
            );
          },
        );

        return AlertDialog(
          title: Text(title),
          content: content,
        );
      },
    );

    // Null value means that dialog was canceled
    if (result != null) {
      setting.value = result;
    }
  }
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

/// Mock [Settings] impl. for preview.
class _MockSettings implements Settings {
  @override
  late final ValueNotifier<String?> acceptedPrivacyPolicyVersion =
      ValueNotifier(null);

  @override
  late final ValueNotifier<String?> acceptedTermsOfServiceVersion =
      ValueNotifier(null);

  @override
  late final ValueNotifier<PdfSigningOption> signingPdfContainer =
      ValueNotifier(PdfSigningOption.pades);

  @override
  late final ValueNotifier<SignatureType> signatureType =
      ValueNotifier(SignatureType.unset);

  @override
  late final ValueNotifier<Certificate?> signingCertificate =
      ValueNotifier(null);

  @override
  late final ValueNotifier<bool> remoteDocumentSigningOnboardingPassed =
      ValueNotifier(false);

  @override
  Future<bool> clear() {
    final props = <ValueNotifier>[
      acceptedPrivacyPolicyVersion,
      acceptedTermsOfServiceVersion,
      signingPdfContainer,
      signatureType,
      signingCertificate,
      remoteDocumentSigningOnboardingPassed
    ];

    for (final prop in props) {
      prop.value = null;
    }

    return Future.value(true);
  }
}
