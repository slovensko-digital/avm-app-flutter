import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../widgets/markdown_text.dart';

/// Modal dialog showing instructions for properly attaching an ID card to a phone.
class IdCardTroubleshootingDialog extends StatelessWidget {
  const IdCardTroubleshootingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      strings.idCardTroubleshootingTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Instruction image (if available)
              Center(
                child: Image.asset(
                  'assets/images/id_card_instruction.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Instructions text
              MarkdownText(
                strings.idCardTroubleshootingInstructions,
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
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'ID Card Troubleshooting Dialog',
  type: IdCardTroubleshootingDialog,
)
Widget previewIdCardTroubleshootingDialog(BuildContext context) {
  return const Scaffold(
    body: Center(
      child: IdCardTroubleshootingDialog(),
    ),
  );
}
