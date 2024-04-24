import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../app_theme.dart' show kPrimaryButtonMinimumSize, kScreenMargin;

/// Start screen to start remote document signing.
class StartRemoteDocumentSigningScreen extends StatelessWidget {
  const StartRemoteDocumentSigningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.signRemoteDocumentTitle),
      ),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final strings = context.strings;
    final child = Column(
      children: [
        const Expanded(
          child: Text("...."),
        ),

        // Primary button
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: null,
          child: Text(strings.buttonScanQrCodeLabel),
        ),
      ],
    );

    return Padding(
      padding: kScreenMargin,
      child: child,
    );
  }

  Future<void> _startQrCodeScanner(BuildContext context) {
    return Future.value(null);
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: '',
  type: StartRemoteDocumentSigningScreen,
)
Widget previewStartRemoteDocumentSigningScreen(BuildContext context) {
  return const StartRemoteDocumentSigningScreen();
}
