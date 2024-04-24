import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';

/// Displays list of paired devices.
class PairedDeviceListScreen extends StatelessWidget {
  const PairedDeviceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.pairedDevicesTitle),
      ),
      body: SafeArea(
        child: _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Žiadne"),
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: '',
  type: PairedDeviceListScreen,
)
Widget previewPairedDeviceListScreen(BuildContext context) {
  return const PairedDeviceListScreen();
}
