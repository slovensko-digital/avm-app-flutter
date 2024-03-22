# Autogram Mobile App (AVM)

## Entry points

- [main](lib/main.dart) - main app
- [preview](lib/preview.dart) - [Widgetbook](https://www.widgetbook.io/blog/getting-started) app

## Key concepts

- Business logic should be separated in **Bloc** and placed in [lib/bloc/](lib/bloc)
  - `NameCubit`
  - separate `sealed class NameState`
- For services and Bloc using `@injectable` and also `Provider`
- For persistent app **preferences** use [`ISettings`](lib/data/settings.dart)
- Custom **widgets**:
  - are placed in [`lib/ui`](lib/ui)
  - should have reasonable previews with `@widgetbook.UseCase` without relying on any `Bloc` or `Provider` types

## Implemented app flows

### Onboarding

User onboarding - starts with one [`OnboardingScreen`](lib/ui/screens/onboarding_screen.dart):

1. [`OnboardingAcceptTermsOfServiceScreen`](lib/ui/screens/onboarding_accept_terms_of_service_screen.dart) 
2. [`OnboardingSelectSigningCertificateScreen`](lib/ui/screens/onboarding_select_signing_certificate_screen.dart)
3. [`OnboardingFinishedScreen`](lib/ui/screens/onboarding_finished_screen.dart)

### Sign single document

Signing of single (PDF, TXT, XML, ...) document using
[`Eidmsdk`](../eidmsdk_flutter/lib/eidmsdk.dart) and
[`AutogramService`](../autogram_sign/lib/src/iautogram_service.dart).

1. [`MainScreen`](lib/ui/screens/main_screen.dart) - to present app features and consume shared
   `File`.
2. [`OpenDocumentScreen`](lib/ui/screens/open_document_screen.dart) - to open `File` using system
   file picker dialog or passed `File`.
   In here, the `Document` is created.
3. [`PreviewDocumentScreen`](lib/ui/screens/preview_document_screen.dart) - here, the document
  visualization is shown.
4. [`SelectCertificateScreen`](lib/ui/screens/select_certificate_screen.dart) - here, the
   `Certificate` using `Eidmsdk` is read from ID card. It may be skipped when it was saved.
5. [`SignDocumentScreen`](lib/ui/screens/sign_document_screen.dart) - here, the document is signed
   using `Eidmsdk` and `AutogramService`.
6. [`PresentSignedDocumentScreen`](lib/ui/screens/present_signed_document_screen.dart) - here, the
   (success / error) result is presented and signed document is saved into "Downloads".

## Scripts

FVM init and Pub get:

```shell
fvm install
```

```shell
fvm flutter pub get
```

To generate code:

```shell
fvm dart run build_runner build --delete-conflicting-outputs
```

Build Android APK:

```shell
fvm flutter build apk
```

Build iOS IPA:

```shell
fvm flutter build ipa
```

Build WEB:

```shell
fvm flutter build web --target=lib/preview.dart
```
