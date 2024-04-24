import 'package:eidmsdk/types.dart';
import 'package:flutter/foundation.dart';
import 'package:notified_preferences/notified_preferences.dart';

import 'pdf_signing_option.dart';
import 'signature_type.dart';

/// Interface for general app settings.
abstract interface class ISettings {
  /// Accepted Terms of Service (ToS) document version value.
  ValueNotifier<int?> get acceptedTermsOfServiceVersion;

  /// The signing container value.
  ValueNotifier<PdfSigningOption> get signingPdfContainer;

  /// The signing [Certificate] value.
  ValueNotifier<Certificate?> get signingCertificate;

  /// The signing [SignatureType] value.
  ValueNotifier<SignatureType?> get signatureType;

  /// Clear all setting.
  Future<bool> clear();
}

/// General app settings.
///
/// Uses **Shared Preferences** - need to call [Settings.initialize] before use.
// TODO Make only "Settings" type and private _SettingsImpl that will be returned by factory fun
class Settings with NotifiedPreferences implements ISettings {
  @override
  late final ValueNotifier<int?> acceptedTermsOfServiceVersion =
      createSetting<int?>(
    key: 'tos.version.accepted',
    initialValue: null,
  );

  @override
  late final ValueNotifier<PdfSigningOption> signingPdfContainer =
      createEnumSetting(
    key: 'signing.pdf.container',
    initialValue: PdfSigningOption.pades,
    values: PdfSigningOption.values,
  );

  @override
  late final ValueNotifier<SignatureType?> signatureType = createSetting(
    // createEnumSetting is NOT nullable
    key: 'signing.signatureType',
    initialValue: null,
    read: (prefs, key) {
      final value = prefs.getString(key);

      return (value == null ? null : SignatureType.values.asNameMap()[value]);
    },
    write: (prefs, key, value) {
      prefs.setStringOrNull(key, value?.name);
    },
  );

  @override
  late final ValueNotifier<Certificate?> signingCertificate =
      createJsonSetting<Certificate?>(
    key: 'signing.certificate',
    initialValue: null,
    fromJson: (json) => Certificate.fromJson(json),
  );
}
