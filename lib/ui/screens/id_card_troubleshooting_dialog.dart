import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'dart:async';

import '../../strings_context.dart';

/// Modal dialog showing instructions for properly attaching an ID card to a phone.
/// Displays animated carousel of instruction images with step-by-step guide.
class IdCardTroubleshootingDialog extends StatefulWidget {
  const IdCardTroubleshootingDialog({super.key});

  @override
  State<IdCardTroubleshootingDialog> createState() => _IdCardTroubleshootingDialogState();
}

class _IdCardTroubleshootingDialogState extends State<IdCardTroubleshootingDialog> {
  int _currentImageIndex = 1;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _scheduleNextChange();
  }

  void _scheduleNextChange() {
    if (!mounted) return;

    final nextIndex = _currentImageIndex == 1 ? 2 : (_currentImageIndex == 2 ? 3 : 1);
    final delay = _currentImageIndex == 1
        ? const Duration(milliseconds: 1650) // 1.65 sec for first image
        : _currentImageIndex == 3
            ? const Duration(seconds: 2) // 2 sec delay between 3 and 1
            : const Duration(milliseconds: 650); // 0.65 sec delay for 2->3

    _animationTimer = Timer(delay, () {
      if (mounted) {
        setState(() {
          _currentImageIndex = nextIndex;
        });
        _scheduleNextChange();
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  strings.idCardTroubleshootingTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                // Animated carousel of instruction images
                Center(
                  child: SvgPicture.asset(
                    'assets/images/phone_id_card_$_currentImageIndex.svg',
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) => const SizedBox(
                      width: 280,
                      height: 280,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Instructions text
                MarkdownBody(
                  data: strings.idCardTroubleshootingInstructions,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 15, height: 1.4),
                    strong: const TextStyle(fontWeight: FontWeight.bold),
                    listBullet: const TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(height: 24),
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(strings.closeLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'ID Card Troubleshooting Dialog',
  type: IdCardTroubleshootingDialog,
)
Widget previewIdCardTroubleshootingDialog(BuildContext context) {
  return const IdCardTroubleshootingDialog();
}
