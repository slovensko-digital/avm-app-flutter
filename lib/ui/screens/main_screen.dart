import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../files.dart';
import '../widgets/autogram_logo.dart';
import 'open_document_screen.dart';
import 'settings_screen.dart';

/// Main app screen.
///
/// Navigates to other screens:
///  - [SettingsScreen]
///  - [OpenDocumentScreen]
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static final _logger = Logger('_MainScreenState');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.menu_sharp),
          onPressed: _onShowSettingsRequested,
        ),
        title: const Text("Autogram"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _MainScreenContent(
          onOpenFileRequested: _onOpenFileRequested,
        ),
      ),
    );
  }

  Future<void> _onShowSettingsRequested() {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const SettingsScreen(),
    ));
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
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OpenDocumentScreen(file: file),
        ));
      }
    }
  }
}

class _MainScreenContent extends StatelessWidget {
  final VoidCallback? onOpenFileRequested;

  const _MainScreenContent({required this.onOpenFileRequested});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 64),
        const AutogramLogo(),
        const SizedBox(height: 32),
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
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(kMinInteractiveDimension),
          ),
          onPressed: onOpenFileRequested,
          child: const Text("Vybrať dokument"),
        ),
      ],
    );
  }
}
