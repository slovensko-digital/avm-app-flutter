import 'package:flutter/foundation.dart';
import 'package:notified_preferences/notified_preferences.dart';

import 'pdf_signing_option.dart';

/// Interface for general app settings.
abstract interface class ISettings {
  ValueNotifier<PdfSigningOption> get signingPdfContainer;
}

/// General app settings.
///
/// Uses **Shared Preferences** - need to call [Settings.initialize] before use.
class Settings with NotifiedPreferences implements ISettings {
  /// Used container when signing PDF.
  @override
  late final ValueNotifier<PdfSigningOption> signingPdfContainer =
      createEnumSetting(
    key: 'signing.pdf.container',
    initialValue: PdfSigningOption.pades,
    values: PdfSigningOption.values,
  );
}
