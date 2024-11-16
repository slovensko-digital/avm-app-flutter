import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_sk.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('sk')
  ];

  /// No description provided for @language.
  ///
  /// In sk, this message translates to:
  /// **'Slovensky'**
  String get language;

  /// No description provided for @appName.
  ///
  /// In sk, this message translates to:
  /// **'Autogram v mobile'**
  String get appName;

  /// No description provided for @appTitle.
  ///
  /// In sk, this message translates to:
  /// **'Autogram'**
  String get appTitle;

  /// No description provided for @buttonOKLabel.
  ///
  /// In sk, this message translates to:
  /// **'OK'**
  String get buttonOKLabel;

  /// No description provided for @buttonCancelLabel.
  ///
  /// In sk, this message translates to:
  /// **'Zrušiť'**
  String get buttonCancelLabel;

  /// No description provided for @buttonCloseLabel.
  ///
  /// In sk, this message translates to:
  /// **'Zavrieť'**
  String get buttonCloseLabel;

  /// No description provided for @buttonYesLabel.
  ///
  /// In sk, this message translates to:
  /// **'Áno'**
  String get buttonYesLabel;

  /// No description provided for @buttonNoLabel.
  ///
  /// In sk, this message translates to:
  /// **'Nie'**
  String get buttonNoLabel;

  /// No description provided for @buttonAgreeLabel.
  ///
  /// In sk, this message translates to:
  /// **'Súhlasím'**
  String get buttonAgreeLabel;

  /// No description provided for @buttonAcknowledgeAndAgreeLabel.
  ///
  /// In sk, this message translates to:
  /// **'Rozumiem a súhlasím'**
  String get buttonAcknowledgeAndAgreeLabel;

  /// No description provided for @buttonDisagreeLabel.
  ///
  /// In sk, this message translates to:
  /// **'Nesúhlasím'**
  String get buttonDisagreeLabel;

  /// No description provided for @buttonRetryLabel.
  ///
  /// In sk, this message translates to:
  /// **'Zopakovať'**
  String get buttonRetryLabel;

  /// No description provided for @buttonTryAgainLabel.
  ///
  /// In sk, this message translates to:
  /// **'Skúsiť znova'**
  String get buttonTryAgainLabel;

  /// No description provided for @buttonInitialSetupLabel.
  ///
  /// In sk, this message translates to:
  /// **'Nastaviť Autogram'**
  String get buttonInitialSetupLabel;

  /// No description provided for @buttonOpenDocumentLabel.
  ///
  /// In sk, this message translates to:
  /// **'Vybrať dokument'**
  String get buttonOpenDocumentLabel;

  /// No description provided for @buttonSignLabel.
  ///
  /// In sk, this message translates to:
  /// **'Podpísať'**
  String get buttonSignLabel;

  /// No description provided for @buttonSkipLabel.
  ///
  /// In sk, this message translates to:
  /// **'Preskočiť'**
  String get buttonSkipLabel;

  /// No description provided for @buttonScanQrCodeLabel.
  ///
  /// In sk, this message translates to:
  /// **'Skenovať QR kód'**
  String get buttonScanQrCodeLabel;

  /// No description provided for @buttonSelectCertificateLabel.
  ///
  /// In sk, this message translates to:
  /// **'Vybrať certifikát'**
  String get buttonSelectCertificateLabel;

  /// No description provided for @buttonSignWithCertificateLabel.
  ///
  /// In sk, this message translates to:
  /// **'Podpísať ako {subject}'**
  String buttonSignWithCertificateLabel(Object subject);

  /// No description provided for @buttonSignWithDifferentCertificateLabel.
  ///
  /// In sk, this message translates to:
  /// **'Podpísať iným certifikátom'**
  String get buttonSignWithDifferentCertificateLabel;

  /// No description provided for @deepLinkParseErrorMessage.
  ///
  /// In sk, this message translates to:
  /// **'Nepodporovaný alebo nesprávny odkaz:\n{error}'**
  String deepLinkParseErrorMessage(Object error);

  /// No description provided for @stepIndicatorText.
  ///
  /// In sk, this message translates to:
  /// **'Krok {stepNumber} z {totalSteps}'**
  String stepIndicatorText(Object stepNumber, Object totalSteps);

  /// No description provided for @notificationPermissionRationaleTitle.
  ///
  /// In sk, this message translates to:
  /// **'Povoliť upozornenia'**
  String get notificationPermissionRationaleTitle;

  /// No description provided for @notificationPermissionRationaleMessage.
  ///
  /// In sk, this message translates to:
  /// **'Na zaslanie upozornení o dokumentoch na podpis potrebujeme povolenie.'**
  String get notificationPermissionRationaleMessage;

  /// No description provided for @menuTitle.
  ///
  /// In sk, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In sk, this message translates to:
  /// **'Nastavenia'**
  String get settingsTitle;

  /// No description provided for @signRemoteDocumentTitle.
  ///
  /// In sk, this message translates to:
  /// **'Podpísať vzdialený dokument'**
  String get signRemoteDocumentTitle;

  /// No description provided for @aboutLabel.
  ///
  /// In sk, this message translates to:
  /// **'O aplikácii'**
  String get aboutLabel;

  /// No description provided for @signingPdfContainerTitle.
  ///
  /// In sk, this message translates to:
  /// **'Podpisovanie PDF'**
  String get signingPdfContainerTitle;

  /// No description provided for @signatureTypeErrorHeading.
  ///
  /// In sk, this message translates to:
  /// **'Chyba pri načítaní parametrov podpisu'**
  String get signatureTypeErrorHeading;

  /// No description provided for @signatureTypeTitle.
  ///
  /// In sk, this message translates to:
  /// **'Predvolený typ podpisu'**
  String get signatureTypeTitle;

  /// No description provided for @signatureTypeSummary.
  ///
  /// In sk, this message translates to:
  /// **'{name, select, withoutTimestamp {Vlastnoručný podpis} withTimestamp {Osvedčený podpis} other {Spýtať sa pri podpisovaní}}'**
  String signatureTypeSummary(String name);

  /// No description provided for @signatureTypeValueTitle.
  ///
  /// In sk, this message translates to:
  /// **'{name, select, withoutTimestamp {Vlastnoručný podpis} withTimestamp {Osvedčený podpis} other {-}}'**
  String signatureTypeValueTitle(String name);

  /// No description provided for @signatureTypeValueSubtitle.
  ///
  /// In sk, this message translates to:
  /// **'{name, select, withoutTimestamp {Ako keby ste tento dokument podpísali na papieri.\nBez časovej pečiatky.} withTimestamp {Ako keby ste podpis overili u notára.\nObsahuje časovú pečiatku.}  other {-}}'**
  String signatureTypeValueSubtitle(String name);

  /// No description provided for @signingCertificateTitle.
  ///
  /// In sk, this message translates to:
  /// **'Predvolený podpisový certifikát'**
  String get signingCertificateTitle;

  /// No description provided for @pairedDevicesTitle.
  ///
  /// In sk, this message translates to:
  /// **'Spárované zariadenia'**
  String get pairedDevicesTitle;

  /// No description provided for @pairedDevicesSummary.
  ///
  /// In sk, this message translates to:
  /// **'{count, plural, zero{žiadne} one{1 zariadenie} few{{count} zariadenia} other{{count} zariadení}}'**
  String pairedDevicesSummary(num count);

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In sk, this message translates to:
  /// **'Ochrana osobných údajov'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyUrl.
  ///
  /// In sk, this message translates to:
  /// **'https://sluzby.slovensko.digital/autogram-v-mobile/ochrana-osobnych-udajov'**
  String get privacyPolicyUrl;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In sk, this message translates to:
  /// **'Podmienky používania'**
  String get termsOfServiceTitle;

  /// No description provided for @termsOfServiceUrl.
  ///
  /// In sk, this message translates to:
  /// **'https://sluzby.slovensko.digital/autogram-v-mobile/vseobecne-obchodne-podmienky'**
  String get termsOfServiceUrl;

  /// No description provided for @aboutTitle.
  ///
  /// In sk, this message translates to:
  /// **'O aplikácii'**
  String get aboutTitle;

  /// No description provided for @eidSDKLicenseText.
  ///
  /// In sk, this message translates to:
  /// **'Na komunikáciu s čipom občianskeho preukazu je použitá knižnica eID mSDK od Ministerstva vnútra Slovenskej republiky. Knižnica eID mSDK a podmienky jej použitia sú zverejnené na stránke „<https://github.com/eidmsdk>“.'**
  String get eidSDKLicenseText;

  /// No description provided for @aboutAuthorsText.
  ///
  /// In sk, this message translates to:
  /// **'Autormi tohto projektu sú [freevision s.r.o.](https://freevision.sk/?utm_source=digital.slovensko.avm), [Služby Slovensko.Digital, s.r.o.](https://ekosystem.slovensko.digital/?utm_source=digital.slovensko.avm) a ďalší dobrovoľníci. Prevádzku zabezpečuje [Služby Slovensko.Digital, s.r.o.](https://ekosystem.slovensko.digital/?utm_source=digital.slovensko.avm)\n\nZdrojové kódy sú dostupné na [GitHub-e organizácie Slovensko.Digital](https://github.com/slovensko-digital/avm-app-flutter).'**
  String get aboutAuthorsText;

  /// No description provided for @thirdPartyLicensesLabel.
  ///
  /// In sk, this message translates to:
  /// **'Licencie knižníc tretích strán'**
  String get thirdPartyLicensesLabel;

  /// No description provided for @introHeading.
  ///
  /// In sk, this message translates to:
  /// **'Nový, lepší a krajší podpisovač v mobile'**
  String get introHeading;

  /// No description provided for @introBody.
  ///
  /// In sk, this message translates to:
  /// **'Začnite výberom dokumentu na:\n ✅ Jednoduché podpisovanie\n ✅ Rýchle overenie podpisov'**
  String get introBody;

  /// No description provided for @onboardingFinishedHeading.
  ///
  /// In sk, this message translates to:
  /// **'Autogram je pripravený'**
  String get onboardingFinishedHeading;

  /// No description provided for @onboardingFinishedBody.
  ///
  /// In sk, this message translates to:
  /// **'Začnite výberom dokumentu na:\n ✅ Jednoduché podpisovanie'**
  String get onboardingFinishedBody;

  /// No description provided for @qrCodeScannerInfoBody.
  ///
  /// In sk, this message translates to:
  /// **'Prosím nasmerujte kameru\nna QR kód na obrazovke'**
  String get qrCodeScannerInfoBody;

  /// No description provided for @qrCodeScannerUnsupportedContentErrorMessage.
  ///
  /// In sk, this message translates to:
  /// **'Naskenovali ste nepodporovaný alebo neznámy obsah QR kódu.'**
  String get qrCodeScannerUnsupportedContentErrorMessage;

  /// No description provided for @signRemoteDocumentBody1.
  ///
  /// In sk, this message translates to:
  /// **'Mobilom môžete podpisovať aj dokumenty nachádzajúce sa vo vašom počítači, či v informačnom systéme pomocou rozšírenia “Autogram na štátnych weboch“ vo vašom internetovom prehladávači.'**
  String get signRemoteDocumentBody1;

  /// No description provided for @signRemoteDocumentBody2.
  ///
  /// In sk, this message translates to:
  /// **'1. Pri podpisovaní v internetovom prehliadači vo vašom počítači vyberte možnosť “Podpísať mobilom”.\n2. Telefónom naskenujte QR kód z vášho počítača.'**
  String get signRemoteDocumentBody2;

  /// No description provided for @openDocumentTitle.
  ///
  /// In sk, this message translates to:
  /// **'Otváranie dokumentu'**
  String get openDocumentTitle;

  /// No description provided for @openDocumentErrorTitle.
  ///
  /// In sk, this message translates to:
  /// **'Chyba pri vytváraní dokumentu'**
  String get openDocumentErrorTitle;

  /// No description provided for @previewDocumentTitle.
  ///
  /// In sk, this message translates to:
  /// **'Náhľad dokumentu'**
  String get previewDocumentTitle;

  /// No description provided for @previewDocumentErrorHeading.
  ///
  /// In sk, this message translates to:
  /// **'Chyba pri načítaní vizualizácie dokumentu'**
  String get previewDocumentErrorHeading;

  /// No description provided for @shareDocumentText.
  ///
  /// In sk, this message translates to:
  /// **'\n\nSúbor z aplikácie Autogram v mobile'**
  String get shareDocumentText;

  /// No description provided for @documentVisualizationCannotVisualizeTypeError.
  ///
  /// In sk, this message translates to:
  /// **'Neviem vizualizovať {type} typ.'**
  String documentVisualizationCannotVisualizeTypeError(Object type);

  /// No description provided for @documentValidationLoadingLabel.
  ///
  /// In sk, this message translates to:
  /// **'Prebieha overovanie podpisov'**
  String get documentValidationLoadingLabel;

  /// No description provided for @documentValidationNoSignaturesLabel.
  ///
  /// In sk, this message translates to:
  /// **'Dokument neobsahuje **žiadny podpis**'**
  String get documentValidationNoSignaturesLabel;

  /// No description provided for @documentValidationHasInvalidSignaturesLabel.
  ///
  /// In sk, this message translates to:
  /// **'Dokument obsahuje **neplatné podpisy**'**
  String get documentValidationHasInvalidSignaturesLabel;

  /// No description provided for @documentValidationHasValidSignaturesLabel.
  ///
  /// In sk, this message translates to:
  /// **'{count, plural, one {Dokument obsahuje **1 podpis**} few {Dokument obsahuje **{count} podpisy**} many {Dokument obsahuje {count} podpisov**} other {Dokument obsahuje **{count} podpisov**}}'**
  String documentValidationHasValidSignaturesLabel(num count);

  /// No description provided for @documentValidationSignaturesHeading.
  ///
  /// In sk, this message translates to:
  /// **'Podpisy v dokumente'**
  String get documentValidationSignaturesHeading;

  /// No description provided for @selectCertificateTitle.
  ///
  /// In sk, this message translates to:
  /// **'Výber typu podpisu'**
  String get selectCertificateTitle;

  /// No description provided for @selectSigningCertificateTitle.
  ///
  /// In sk, this message translates to:
  /// **'Nastavenie certifikátu'**
  String get selectSigningCertificateTitle;

  /// No description provided for @selectSigningCertificateBody.
  ///
  /// In sk, this message translates to:
  /// **'Na podpisovanie mobilom potrebujete disponovať vhodným podpisovým certifikátom. Podpisový certifikát si môžete nastaviť aj neskôr počas podpisovania prvého dokumentu.\n\n\nAk si prajete nastaviť podpisový certifikát teraz, pripravte si, prosím, občiansky preukaz a nasledujte inštrukcie na obrazovke.'**
  String get selectSigningCertificateBody;

  /// No description provided for @selectSigningCertificateCanceledHeading.
  ///
  /// In sk, this message translates to:
  /// **'Čítanie certifikátu bolo prerušené'**
  String get selectSigningCertificateCanceledHeading;

  /// No description provided for @selectSigningCertificateCanceledBody.
  ///
  /// In sk, this message translates to:
  /// **'Skúste prosím znovu načítať certifikát z vášho občianskeho preukazu.'**
  String get selectSigningCertificateCanceledBody;

  /// No description provided for @selectSigningCertificateNoCertificateHeading.
  ///
  /// In sk, this message translates to:
  /// **'Certifikát nebol nájdený'**
  String get selectSigningCertificateNoCertificateHeading;

  /// No description provided for @selectSigningCertificateNoCertificateBody.
  ///
  /// In sk, this message translates to:
  /// **'Nepodarilo sa nájsť certifikát pre **kvalifikovaný elektronický podpis**.\n\nCertifikát je potrebné vydať v aplikácii “eID Klient”, prípadne použiť iný občiansky preukaz.\nNávod na vydanie certifikátu nájdete na [navody.digital](https://navody.digital/zivotne-situacie/aktivacia-eid/krok/certifikaty).'**
  String get selectSigningCertificateNoCertificateBody;

  /// No description provided for @selectSigningCertificateErrorHeading.
  ///
  /// In sk, this message translates to:
  /// **'Chyba pri načítavaní certifikátov z občianskeho preukazu.'**
  String get selectSigningCertificateErrorHeading;

  /// No description provided for @certificateIssuer.
  ///
  /// In sk, this message translates to:
  /// **'Vydavateľ: {text}'**
  String certificateIssuer(Object text);

  /// No description provided for @certificateIssuerLabel.
  ///
  /// In sk, this message translates to:
  /// **'Vydavateľ'**
  String get certificateIssuerLabel;

  /// No description provided for @certificateSubjectLabel.
  ///
  /// In sk, this message translates to:
  /// **'Vydaný pre'**
  String get certificateSubjectLabel;

  /// No description provided for @certificateValidityLabel.
  ///
  /// In sk, this message translates to:
  /// **'Platnosť'**
  String get certificateValidityLabel;

  /// No description provided for @certificateValidityNotBeforeLabel.
  ///
  /// In sk, this message translates to:
  /// **'Platný od'**
  String get certificateValidityNotBeforeLabel;

  /// No description provided for @certificateValidityNotAfterLabel.
  ///
  /// In sk, this message translates to:
  /// **'Platný do'**
  String get certificateValidityNotAfterLabel;

  /// No description provided for @certificateNotAfter.
  ///
  /// In sk, this message translates to:
  /// **'Platný do: {text}'**
  String certificateNotAfter(Object text);

  /// No description provided for @signDocumentTitle.
  ///
  /// In sk, this message translates to:
  /// **'Podpisovanie dokumentu'**
  String get signDocumentTitle;

  /// No description provided for @signDocumentCanceledHeading.
  ///
  /// In sk, this message translates to:
  /// **'Podpisovanie pomocou občianskeho preukazu bolo prerušené'**
  String get signDocumentCanceledHeading;

  /// No description provided for @signDocumentErrorHeading.
  ///
  /// In sk, this message translates to:
  /// **'Pri podpisovaní sa vyskytla chyba'**
  String get signDocumentErrorHeading;

  /// No description provided for @documentSigningSuccessTitle.
  ///
  /// In sk, this message translates to:
  /// **'Dokument bol úspešne podpísaný'**
  String get documentSigningSuccessTitle;

  /// No description provided for @saveSignedDocumentSuccessMessage.
  ///
  /// In sk, this message translates to:
  /// **'Dokument bol uložený do **{directory}** pod názvom [{name}](#).'**
  String saveSignedDocumentSuccessMessage(Object directory, Object name);

  /// No description provided for @saveSignedDocumentErrorMessage.
  ///
  /// In sk, this message translates to:
  /// **'Pri ukladaní súboru sa vyskytla chyba:\n{error}'**
  String saveSignedDocumentErrorMessage(Object error);

  /// No description provided for @shareSignedDocumentLabel.
  ///
  /// In sk, this message translates to:
  /// **'Zdieľať podpísaný dokument'**
  String get shareSignedDocumentLabel;

  /// No description provided for @shareSignedDocumentText.
  ///
  /// In sk, this message translates to:
  /// **'\n\nPodpísané aplikáciou Autogram v mobile'**
  String get shareSignedDocumentText;

  /// No description provided for @shareSignedDocumentErrorMessage.
  ///
  /// In sk, this message translates to:
  /// **'Pri zdieľaní súboru sa vyskytla chyba:\n{error}'**
  String shareSignedDocumentErrorMessage(Object error);

  /// No description provided for @empty.
  ///
  /// In sk, this message translates to:
  /// **''**
  String get empty;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['sk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'sk': return AppLocalizationsSk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
