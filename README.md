# Autogram Mobile App (AVM)

## Entry points

- [main](lib/main.dart) - main app
- [preview](lib/preview.dart) - [Widgetbook](https://www.widgetbook.io/blog/getting-started) app

## Flows

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
