import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../app_service.dart';
import '../../di.dart';
import '../../strings_context.dart';
import '../app_theme.dart' show kPrimaryButtonMinimumSize, kScreenMargin;
import 'qr_code_scanner_screen.dart';

/// Screen to start remote document signing.
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(strings.signRemoteDocumentBody1),
                const SizedBox(height: 30),
                Text(strings.signRemoteDocumentBody2),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),

        // Primary button
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: () {
            _startQrCodeScanner(context);
          },
          child: Text(strings.buttonScanQrCodeLabel),
        ),
      ],
    );

    return Padding(
      padding: kScreenMargin,
      child: child,
    );
  }

  Future<void> _startQrCodeScanner(BuildContext context) async {
    const screen = QRCodeScannerScreen();
    final route = MaterialPageRoute(builder: (_) => screen);
    final result = await Navigator.of(context).push(route);

    if (result is String) {
      getIt.get<AppService>().newIncomingUri(result);
    }
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