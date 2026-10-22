import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../data/avm_server.dart';
import '../../strings_context.dart';
import 'document_validation_strip.dart';

/// Presents other than the official [server], from which the document is
/// signed, so the user knows who provides the document.
///
/// Displayed instead of [DocumentValidationStrip], as signatures validated by
/// such server can't be trusted.
class DocumentServerStrip extends StatelessWidget {
  final AvmServer server;

  const DocumentServerStrip({super.key, required this.server});

  @override
  Widget build(BuildContext context) {
    const foregroundColor = Colors.black;
    final label = context.strings.documentServerLabel;

    return Semantics(
      label: "$label ${server.authority}",
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: const Color(0xFFEBCFAA),
        child: Row(
          children: [
            const Icon(Icons.dns_outlined, color: foregroundColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: "$label ",
                  children: [
                    TextSpan(
                      text: server.authority,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                style: const TextStyle(color: foregroundColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: '',
  type: DocumentServerStrip,
)
Widget previewDocumentServerStrip(BuildContext context) {
  final authority = context.knobs.string(
    label: 'Server',
    initialValue: 'avm.example.org',
  );

  return DocumentServerStrip(server: AvmServer(authority));
}
