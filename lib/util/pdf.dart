import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A set of PDF utils.
abstract class PDF {
  /// Returns new PDF document from [text].
  @Deprecated("This prints only single page and without Unicode support.")
  static Future<Uint8List> fromText(String text) {
    final doc = pw.Document()
      ..addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => pw.Text(text),
        ),
      ); // Page

    return doc.save();
  }
}
