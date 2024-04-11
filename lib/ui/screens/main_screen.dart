import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../app_service.dart';
import '../../files.dart';
import '../app_theme.dart';
import '../widgets/autogram_logo.dart';
import 'open_document_screen.dart';
import 'settings_screen.dart';

/// Main app screen that presents app features.
///
/// Has ability to open new file or navigate to Settings.
///
/// Navigates to other screens:
///  - [SettingsScreen]
///  - [OpenDocumentScreen]
class MainScreen extends StatefulWidget {
  final Uri? sharedFile;

  const MainScreen({super.key, required this.sharedFile});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static final _logger = Logger('_MainScreenState');

  late final AppService _appService;

  @override
  void initState() {
    super.initState();

    _appService = GetIt.instance.get<AppService>();

    _handleNewSharedFile();
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sharedFile != widget.sharedFile) {
      _handleNewSharedFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _MainAppBar(
        onShowSettingsRequested: _onShowSettingsRequested,
      ),
      body: MainBody(
        onOpenFileRequested: _onOpenFileRequested,
      ),
    );
  }

  void _handleNewSharedFile() {
    final sharedFileUri = widget.sharedFile;

    if (sharedFileUri != null && mounted) {
      // This is only Future that will hopefully return the File
      final Future<File> sharedFile = _appService.getFile(sharedFileUri);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Directly navigate to next screen, which have progress and error handling
        _openNewFile(sharedFile);
      });
    }
  }

  Future<void> _onShowSettingsRequested() {
    const screen = SettingsScreen();
    final route = MaterialPageRoute(builder: (_) => screen);

    return Navigator.of(context).push(route);
  }

  Future<void> _openNewFile(FutureOr<File> file) {
    final screen = OpenDocumentScreen(file: file);
    final route = MaterialPageRoute(builder: (_) => screen);

    // Removing other routes because might want to open another file from Files;
    // in that case we will stop any previous signing flow
    return Navigator.of(context).pushAndRemoveUntil(
      route,
      (final route) => route.settings.name == '/',
    );
  }

  Future<void> _onOpenFileRequested() async {
    _logger.fine('Requested to open file.');

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Vyberte súbor",
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: Files.supportedExtensions,
    );

    final selectedFile = result?.files.singleOrNull;

    if (selectedFile != null) {
      File file = File(selectedFile.path!);

      _logger.fine('File selected: $file');

      if (context.mounted) {
        _openNewFile(file);
      }
    }
  }
}

// ignore: non_constant_identifier_names
AppBar _MainAppBar({
  VoidCallback? onShowSettingsRequested,
}) {
  return AppBar(
    foregroundColor: kMainAppBarForegroundColor,
    backgroundColor: kMainAppBarBackgroundColor,
    leading: IconButton(
      icon: const Icon(Icons.menu_sharp),
      onPressed: onShowSettingsRequested,
    ),
    title: const Text(
      "Autogram v mobile",
      style: TextStyle(
        color: kMainAppBarForegroundColor,
      ),
    ),
  );
}

/// [MainScreen] body.
class MainBody extends StatelessWidget {
  final VoidCallback? onOpenFileRequested;

  const MainBody({super.key, required this.onOpenFileRequested});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kScreenMargin,
      child: Column(
        children: [
          const SizedBox(height: 96),
          const Padding(
            padding: EdgeInsets.all(48),
            child: AutogramLogo(),
          ),
          const Text(
            "Nový, lepší a krajší podpisovač v\u{00A0}mobile",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            "Začnite výberom dokumentu na:\n ✅ Jednoduché podpisovanie",
          ),
          const Spacer(),

          // Primary button
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: kPrimaryButtonMinimumSize,
            ),
            onPressed: onOpenFileRequested,
            child: const Text("Vybrať dokument"),
          ),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'main',
  type: AppBar,
)
Widget previewMainAppBar(BuildContext context) {
  return SizedBox(
    height: kToolbarHeight,
    child: _MainAppBar(
      onShowSettingsRequested: () {
        developer.log("onShowSettingsRequested");
      },
    ),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'MainBody',
  type: MainBody,
)
Widget previewMainBody(BuildContext context) {
  return MainBody(
    onOpenFileRequested: () {},
  );
}
