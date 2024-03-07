import 'package:flutter/material.dart';

import '../widgets/preference_tile.dart';

/// App setting screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Nastavenia"),
      ),
      body: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends StatelessWidget {
  const _SettingsScreenContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: true,
      padding: const EdgeInsets.all(16),
      children: [
        PreferenceTile(
          title: "Podpisovanie PDF",
          summary: "PADES",
          onPressed: () => _openPdfSigningSettings(context),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Future<void> _openPdfSigningSettings(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text("Podpisovanie PDF"),
          // content: ,
          // TODO Impl AlertDialog content
          // PAdES / XAdES ASiC-E / CAdES ASiC-E
        );
      },
    );
  }
}
