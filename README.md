# Autogram v mobile (AVM)

Flutter aplikácia pre Android a iOS. Podpisovač Autogram v mobile umožňuje podpisovanie elektronickým občianskym preukazom s NFC rozhraním. Detailnejšie info o arhitektúre projektu sa nachádzajú v repozitári [AVM server](https://github.com/slovensko-digital/avm-server).

[Autogram v mobile](https://sluzby.slovensko.digital/autogram-v-mobile/) vytvorili freevision s.r.o., Služby Slovensko.Digital s.r.o. s dobrovoľníkmi pod EUPL v1.2 licenciou. Prevádzkovateľom je Služby Slovensko.Digital s.r.o.. Prípadné issues riešime v [GitHub projekte](https://github.com/orgs/slovensko-digital/projects/5) alebo rovno v tomto repozitári.

Celý projekt sa skladá z viacerých častí:
- **Server**
  - [AVM server](https://github.com/slovensko-digital/avm-server) - Ruby on Rails API server poskytujúci funkcionalitu zdieľania a podpisovania dokumentov.
  - [AVM service](https://github.com/slovensko-digital/avm-service) - Java microservice využívajúci Digital Signature Service knižnicu pre elektronické podpisovanie a generovanie vizualizácie dokumentov.
- **Mobilná aplikácia**
  - [AVM app Flutter](https://github.com/slovensko-digital/avm-app-flutter) - Flutter aplikácia pre iOS a Android.
  - [AVM client Dart](https://github.com/slovensko-digital/avm-client-dart) - Dart API klient pre komunikáciu s AVM serverom.
  - [eID mSDK Flutter](https://github.com/slovensko-digital/eidmsdk-flutter) - Flutter wrapper "štátneho" [eID mSDK](https://github.com/eIDmSDK) pre komunikáciu s občianskym preukazom.
- [**Autogram extension**](https://github.com/slovensko-digital/autogram-extension) - Rozšírenie do prehliadača, ktoré umožňuje podpisovanie priamo na štátnych portáloch.


## Dart aplikácia
### Entry points

- [main](lib/main.dart) - main app
- [preview](lib/preview.dart) - [Widgetbook](https://www.widgetbook.io/blog/getting-started) app

### Key concepts

- Business logic should be separated in **Bloc** and placed in [lib/bloc/](lib/bloc)
  - `NameCubit`
  - separate `sealed class NameState`
- For services and Bloc using `@injectable` and also `Provider`
- For persistent app **preferences** use [`ISettings`](lib/data/settings.dart)
- Custom **widgets**:
  - are placed in [`lib/ui`](lib/ui)
  - should have reasonable previews with `@widgetbook.UseCase` without relying on any `Bloc` or `Provider` types

### Implemented app flows

#### Onboarding

User onboarding - started with [`Onboarding`](lib/ui/onboarding.dart):

1. Accept Privacy Policy using [`OnboardingAcceptDocumentScreen`](lib/ui/screens/onboarding_accept_document_screen.dart)
2. Accept Terms of Service using same [`OnboardingAcceptDocumentScreen`](lib/ui/screens/onboarding_accept_document_screen.dart)  
3. optionally [`OnboardingSelectSigningCertificateScreen`](lib/ui/screens/onboarding_select_signing_certificate_screen.dart)
4. Presenting finish - [`OnboardingFinishedScreen`](lib/ui/screens/onboarding_finished_screen.dart)

#### Sign single document

Signing of single (PDF, TXT, image, eForms XML, ...) document using
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

#### Remote document signing

Started with [`RemoteDocumentSigning`](lib/ui/remote_document_signing.dart).
It's similar to [Sign single document](#sign-single-document), but starts with:

- [`StartRemoteDocumentSigningScreen`](lib/ui/screens/start_remote_document_signing_screen.dart)
- [`QRCodeScannerScreen`](lib/ui/screens/qr_code_scanner_screen.dart)

### Scripts

FVM init and Pub get:

```shell
fvm install
```

Activate `flutterfire_cli` for local Dart (NOT system Dart):

```shell
fvm dart pub global activate flutterfire_cli
```

```shell
fvm flutter pub get
```

Run all Flutter tests:

```shell
fvm flutter test
```

Generate i18n code:

```shell
fvm flutter gen-l10n
```

Generate code:

```shell
fvm dart run build_runner build --delete-conflicting-outputs
```

Build **Android** APK:

eid-mSDK binaries are hosted on GitHub package registry. To access the package during build process environment variable `EIDMSDK_ACCESS_TOKEN` needs to be set to a GitHub Personal Access Token that has permission to read package registry.

```shell
fvm flutter build apk
```

Build **iOS** IPA:

```shell
fvm flutter build ipa
```

Build **WEB**:

```shell
fvm flutter build web --target=lib/preview.dart
```

### Identifiers and links

- Android Application ID, [Apple Bundle/App ID](https://developer.apple.com/account/resources/identifiers/bundleId/edit/832594XXZD): `digital.slovensko.avm`
- Apple Team ID: `44U4JSRX4Z` (Služby Slovensko.Digital, s.r.o.)
- Apple App Store ID: [`6479985251`](https://appstoreconnect.apple.com/apps/6479985251/distribution/info), SKU: `avm`
- Firebase: [`digital-slovensko-avm`](https://console.firebase.google.com/project/digital-slovensko-avm/overview)
