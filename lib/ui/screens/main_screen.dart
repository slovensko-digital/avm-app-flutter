import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../app_service.dart';
import '../../data/settings.dart';
import '../../deep_links.dart';
import '../../di.dart';
import '../../services/encryption_key_registry.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import '../widgets/autogram_logo.dart';
import 'main_menu_screen.dart';
import 'onboarding_screen.dart';
import 'open_document_screen.dart';
import 'preview_document_screen.dart';
import 'start_remote_document_signing_screen.dart';

/// Main app screen that presents app features.
///
/// Has ability to:
/// - open new file and navigate next to [OpenDocumentScreen]
/// - show [MainMenuScreen]
/// - navigate to [StartRemoteDocumentSigningScreen]
/// - start Onboarding by navigating to [OnboardingScreen]
class MainScreen extends StatefulWidget {
  final Uri? incomingUri;

  const MainScreen({super.key, required this.incomingUri});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static final _logger = Logger((MainScreen).toString());

  @override
  void initState() {
    super.initState();

    _handleNewIncomingUri();
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Using !identical instead of "!=" for case when sharing same file URI
    if (!identical(oldWidget.incomingUri, widget.incomingUri)) {
      _handleNewIncomingUri();
    }
  }

  @override
  Widget build(BuildContext context) {
    final acceptedTermsOfServiceVersion =
        context.read<ISettings>().acceptedTermsOfServiceVersion;

    return ValueListenableBuilder(
      valueListenable: acceptedTermsOfServiceVersion,
      builder: (context, version, _) {
        final showQrCodeScannerIcon = version != null;

        return Scaffold(
          appBar: _MainAppBar(
            context: context,
            showQrCodeScannerIcon: showQrCodeScannerIcon,
            onMenuPressed: _showMenu,
            onQrCodeScannerPressed: _showQrCodeScanner,
          ),
          body: _Body(
            onStartOnboardingRequested: _onStartOnboardingRequested,
            onOpenFileRequested: _onOpenFileRequested,
          ),
        );
      },
    );
  }

  void _handleNewIncomingUri() {
    final uri = widget.incomingUri;

    if (uri != null && mounted) {
      switch (uri.scheme) {
        case "file" || "content":
          // This is only Future that will (hopefully) return the File
          final Future<File> sharedFile = getIt.get<AppService>().getFile(uri);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Directly navigate to next screen, which have progress and error handling
            _openNewFile(sharedFile);
          });
          break;

        case "https" || "avm":
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleDeepLink(uri);
          });
          break;
      }
    }
  }

  Future<void> _showMenu() {
    const screen = MainMenuScreen();

    return showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => screen,
    );
  }

  Future<void> _showQrCodeScanner() {
    const screen = StartRemoteDocumentSigningScreen();
    final route = MaterialPageRoute(builder: (_) => screen);

    return Navigator.of(context).push(route);
  }

  Future<void> _openNewFile(FutureOr<File> file) {
    getIt.get<EncryptionKeyRegistry>().newValue();

    final screen = OpenDocumentScreen(file: file);
    final route = MaterialPageRoute(builder: (_) => screen);

    // Removing other routes because might want to open another file from Files;
    // in that case we will stop any previous signing flow
    return Navigator.of(context).pushAndRemoveUntil(
      route,
      (final route) => route.settings.name == '/',
    );
  }

  void _handleDeepLink(Uri uri) {
    DeepLinkAction action;

    try {
      action = parseDeepLinkAction(uri);
    } catch (error) {
      final message = context.strings.deepLinkParseErrorMessage(error);
      final snackBar = SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);

      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    _logger.info("Handling Deep Link action: $action");

    if (action is SignRemoteDocumentAction) {
      getIt.get<EncryptionKeyRegistry>().value = action.key;

      final screen = PreviewDocumentScreen(
        documentId: action.guid,
        file: null,
      );
      final route = MaterialPageRoute(builder: (_) => screen);

      // Removing other routes because might want to open another file from URL;
      // in that case we will stop any previous signing flow
      Navigator.of(context).pushAndRemoveUntil(
        route,
        (final route) => route.settings.name == '/',
      );
    }
  }

  Future<void> _onStartOnboardingRequested() {
    _logger.fine('Requested to start Onboarding.');

    const screen = OnboardingScreen();
    final route = MaterialPageRoute(builder: (_) => screen);

    return Navigator.of(context).push(route).then((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map;
      final result = arguments['result'];

      if (result == true) {
        // TODO Call this function right when it was pressed on that screen
        // Pass via Provider and drop this "arguments" usage
        _onOpenFileRequested();
      }
    });
  }

  Future<void> _onOpenFileRequested() async {
    _logger.fine('Requested to open file.');

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: context.strings.buttonOpenDocumentLabel,
    );

    final selectedFile = result?.files.singleOrNull;

    if (selectedFile != null) {
      final File file = File(selectedFile.path!);

      _logger.fine('File selected: $file');

      if (context.mounted) {
        _openNewFile(file);
      }
    }
  }
}

// ignore: non_constant_identifier_names
AppBar _MainAppBar({
  required BuildContext context,
  bool showQrCodeScannerIcon = true,
  VoidCallback? onMenuPressed,
  VoidCallback? onQrCodeScannerPressed,
}) {
  final iconColor = Theme.of(context).colorScheme.onSecondary;
  final colorFilter = ColorFilter.mode(iconColor, BlendMode.srcIn);

  return AppBar(
    foregroundColor: kMainAppBarForegroundColor,
    backgroundColor: kMainAppBarBackgroundColor,
    leading: IconButton(
      icon: SvgPicture.asset(
        'assets/icons/menu.svg',
        colorFilter: colorFilter,
      ),
      onPressed: onMenuPressed,
    ),
    actions: [
      if (showQrCodeScannerIcon)
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/qr_code_scanner.svg',
            colorFilter: colorFilter,
          ),
          onPressed: onQrCodeScannerPressed,
        ),
    ],
    title: Builder(builder: (context) {
      return Text(
        context.strings.appName,
        style: const TextStyle(
          color: kMainAppBarForegroundColor,
        ),
      );
    }),
  );
}

/// [MainScreen] body.
class _Body extends StatelessWidget {
  final VoidCallback? onStartOnboardingRequested;
  final VoidCallback? onOpenFileRequested;

  const _Body({
    required this.onStartOnboardingRequested,
    required this.onOpenFileRequested,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Padding(
      padding: kScreenMargin,
      child: Column(
        children: [
          const SizedBox(height: 96),
          const Padding(
            padding: EdgeInsets.all(48),
            child: AutogramLogo(),
          ),
          Text(
            strings.introHeading,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(strings.introBody),
          const Spacer(),

          // Primary button
          _buildPrimaryButton(context),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    // Workaround for preview without ISettings
    final listenable =
        (context.read<ISettings?>()?.acceptedTermsOfServiceVersion ??
            ValueNotifier(1));

    return ValueListenableBuilder(
        valueListenable: listenable,
        builder: (context, version, _) {
          final termsOfServiceAreAccepted = (version != null);

          VoidCallback? onPressed;
          String label;

          if (termsOfServiceAreAccepted) {
            onPressed = onOpenFileRequested;
            label = context.strings.buttonOpenDocumentLabel;
          } else {
            onPressed = onStartOnboardingRequested;
            label = context.strings.buttonInitialSetupLabel;
          }

          return FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: kPrimaryButtonMinimumSize,
            ),
            onPressed: onPressed,
            child: Text(label),
          );
        });
  }
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'main',
  type: AppBar,
)
Widget previewMainAppBar(BuildContext context) {
  final showQrCodeScannerIcon = context.knobs.boolean(
    label: "Show QR code scanner",
    initialValue: true,
  );

  return SizedBox(
    height: kToolbarHeight,
    child: _MainAppBar(
      context: context,
      showQrCodeScannerIcon: showQrCodeScannerIcon,
      onMenuPressed: () {
        developer.log("onMenuPressed");
      },
    ),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: '',
  type: MainScreen,
)
Widget previewMainScreen(BuildContext context) {
  return _Body(
    onStartOnboardingRequested: () {
      developer.log("onStartOnboardingRequested");
    },
    onOpenFileRequested: () {
      developer.log("onOpenFileRequested");
    },
  );
}
