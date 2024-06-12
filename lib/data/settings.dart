import 'package:eidmsdk/types.dart';
import 'package:flutter/foundation.dart';
import 'package:notified_preferences/notified_preferences.dart';

import 'pdf_signing_option.dart';
import 'signature_type.dart';

/// Interface for general app settings.
abstract interface class ISettings {
  /// Accepted Privacy Policy document version value.
  ValueNotifier<String?> get acceptedPrivacyPolicyVersion;

  /// Accepted Terms of Service document version value.
  ValueNotifier<String?> get acceptedTermsOfServiceVersion;

  /// The signing container value.
  ValueNotifier<PdfSigningOption> get signingPdfContainer;

  /// The signing [Certificate] value.
  ValueNotifier<Certificate?> get signingCertificate;

  /// The signing [SignatureType] value.
  ValueNotifier<SignatureType> get signatureType;

  /// Whether passed onboarding screen for "Remote Document Signing" feature.
  ValueNotifier<bool> get remoteDocumentSigningOnboardingPassed;

  /// Clear all setting.
  Future<bool> clear();
}

/// General app settings.
///
/// Uses **Shared Preferences** - need to call [Settings.initialize] before use.
// TODO Make only "Settings" type and private _SettingsImpl that will be returned by factory fun
// TODO Register Settings using Injectable as singleton - would need to pass instance into DI so no need to use "async"
class Settings with NotifiedPreferences implements ISettings {
  @override
  late final ValueNotifier<String?> acceptedPrivacyPolicyVersion =
      createSetting<String?>(
    key: 'doc.pp.version.accepted',
    initialValue: null,
  );

  @override
  late final ValueNotifier<String?> acceptedTermsOfServiceVersion =
      createSetting<String?>(
    key: 'doc.tos.version.accepted',
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
  late final ValueNotifier<SignatureType> signatureType = createEnumSetting(
    key: 'signing.signatureType',
    initialValue: SignatureType.unset,
    values: SignatureType.values,
  );

  @override
  late final ValueNotifier<Certificate?> signingCertificate =
      createJsonSetting<Certificate?>(
    key: 'signing.certificate',
    initialValue: null,
    fromJson: (json) => Certificate.fromJson(json),
  );

  @override
  late final ValueNotifier<bool> remoteDocumentSigningOnboardingPassed =
      createSetting(
    key: "onboarding.remoteDocumentSigning.passed",
    initialValue: false,
  );
}
