import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get language => 'Slovensky';

  @override
  String get appName => 'Autogram v mobile';

  @override
  String get appTitle => 'Autogram';

  @override
  String get buttonOKLabel => 'OK';

  @override
  String get buttonCancelLabel => 'Zrušiť';

  @override
  String get buttonCloseLabel => 'Zavrieť';

  @override
  String get buttonYesLabel => 'Áno';

  @override
  String get buttonNoLabel => 'Nie';

  @override
  String get buttonAgreeLabel => 'Súhlasím';

  @override
  String get buttonAcknowledgeAndAgreeLabel => 'Rozumiem a súhlasím';

  @override
  String get buttonDisagreeLabel => 'Nesúhlasím';

  @override
  String get buttonRetryLabel => 'Zopakovať';

  @override
  String get buttonTryAgainLabel => 'Skúsiť znova';

  @override
  String get buttonInitialSetupLabel => 'Nastaviť Autogram';

  @override
  String get buttonOpenDocumentLabel => 'Vybrať dokument';

  @override
  String get buttonSignLabel => 'Podpísať';

  @override
  String get buttonSkipLabel => 'Preskočiť';

  @override
  String get buttonScanQrCodeLabel => 'Skenovať QR kód';

  @override
  String get buttonSelectCertificateLabel => 'Vybrať certifikát';

  @override
  String buttonSignWithCertificateLabel(Object subject) {
    return 'Podpísať ako $subject';
  }

  @override
  String get buttonSignWithDifferentCertificateLabel => 'Podpísať iným certifikátom';

  @override
  String deepLinkParseErrorMessage(Object error) {
    return 'Nepodporovaný alebo nesprávny odkaz:\n$error';
  }

  @override
  String stepIndicatorText(Object stepNumber, Object totalSteps) {
    return 'Krok $stepNumber z $totalSteps';
  }

  @override
  String get notificationPermissionRationaleTitle => 'Povoliť upozornenia';

  @override
  String get notificationPermissionRationaleMessage => 'Na zaslanie upozornení o dokumentoch na podpis potrebujeme povolenie.';

  @override
  String get menuTitle => 'Menu';

  @override
  String get settingsTitle => 'Nastavenia';

  @override
  String get signRemoteDocumentTitle => 'Podpísať vzdialený dokument';

  @override
  String get aboutLabel => 'O aplikácii';

  @override
  String get signingPdfContainerTitle => 'Podpisovanie PDF';

  @override
  String get signatureTypeErrorHeading => 'Chyba pri načítaní parametrov podpisu';

  @override
  String get signatureTypeTitle => 'Predvolený typ podpisu';

  @override
  String signatureTypeSummary(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'withoutTimestamp': 'Vlastnoručný podpis',
        'withTimestamp': 'Osvedčený podpis',
        'other': 'Spýtať sa pri podpisovaní',
      },
    );
    return '$_temp0';
  }

  @override
  String signatureTypeValueTitle(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'withoutTimestamp': 'Vlastnoručný podpis',
        'withTimestamp': 'Osvedčený podpis',
        'other': '-',
      },
    );
    return '$_temp0';
  }

  @override
  String signatureTypeValueSubtitle(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'withoutTimestamp': 'Ako keby ste tento dokument podpísali na papieri.\nBez časovej pečiatky.',
        'withTimestamp': 'Ako keby ste podpis overili u notára.\nObsahuje časovú pečiatku.',
        'other': '-',
      },
    );
    return '$_temp0';
  }

  @override
  String get signingCertificateTitle => 'Predvolený podpisový certifikát';

  @override
  String get pairedDevicesTitle => 'Spárované zariadenia';

  @override
  String pairedDevicesSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zariadení',
      few: '$count zariadenia',
      one: '1 zariadenie',
      zero: 'žiadne',
    );
    return '$_temp0';
  }

  @override
  String get privacyPolicyTitle => 'Ochrana osobných údajov';

  @override
  String get privacyPolicyUrl => 'https://sluzby.slovensko.digital/autogram-v-mobile/ochrana-osobnych-udajov';

  @override
  String get termsOfServiceTitle => 'Podmienky používania';

  @override
  String get termsOfServiceUrl => 'https://sluzby.slovensko.digital/autogram-v-mobile/vseobecne-obchodne-podmienky';

  @override
  String get aboutTitle => 'O aplikácii';

  @override
  String get eidSDKLicenseText => 'Na komunikáciu s čipom občianskeho preukazu je použitá knižnica eID mSDK od Ministerstva vnútra Slovenskej republiky. Knižnica eID mSDK a podmienky jej použitia sú zverejnené na stránke „<https://github.com/eidmsdk>“.';

  @override
  String get aboutAuthorsText => 'Autormi tohto projektu sú [freevision s.r.o.](https://freevision.sk), [Služby Slovensko.Digital, s.r.o.](https://sluzby.slovensko.digital) a ďalší dobrovoľníci. Prevádzku zabezpečuje [Služby Slovensko.Digital, s.r.o.](https://sluzby.slovensko.digital/)\n\nZdrojové kódy sú dostupné na [GitHub-e organizácie Slovensko.Digital](https://github.com/slovensko-digital/avm-app-flutter).';

  @override
  String get thirdPartyLicensesLabel => 'Licencie knižníc tretích strán';

  @override
  String get introHeading => 'Nový, lepší a krajší podpisovač v mobile';

  @override
  String get introBody => 'Začnite výberom dokumentu na:\n ✅ Jednoduché podpisovanie';

  @override
  String get onboardingFinishedHeading => 'Autogram je pripravený';

  @override
  String get onboardingFinishedBody => 'Začnite výberom dokumentu na:\n ✅ Jednoduché podpisovanie';

  @override
  String get qrCodeScannerInfoBody => 'Prosím nasmerujte kameru\nna QR kód na obrazovke';

  @override
  String get qrCodeScannerUnsupportedContentErrorMessage => 'Naskenovali ste nepodporovaný alebo neznámy obsah QR kódu.';

  @override
  String get signRemoteDocumentBody1 => 'Mobilom môžete podpisovať aj dokumenty nachádzajúce sa vo vašom počítači, či v informačnom systéme pomocou rozšírenia “Autogram na štátnych weboch“ vo vašom internetovom prehladávači.';

  @override
  String get signRemoteDocumentBody2 => '1. Pri podpisovaní v internetovom prehliadači vo vašom počítači vyberte možnosť “Podpísať mobilom”.\n2. Telefónom naskenujte QR kód z vášho počítača.';

  @override
  String get openDocumentTitle => 'Otváranie dokumentu';

  @override
  String get openDocumentErrorTitle => 'Chyba pri vytváraní dokumentu';

  @override
  String get previewDocumentTitle => 'Náhľad dokumentu';

  @override
  String get previewDocumentErrorHeading => 'Chyba pri načítaní vizualizácie dokumentu';

  @override
  String get shareDocumentText => '\n\nSúbor z aplikácie Autogram v mobile';

  @override
  String documentVisualizationCannotVisualizeTypeError(Object type) {
    return 'Neviem vizualizovať $type typ.';
  }

  @override
  String get selectCertificateTitle => 'Výber typu podpisu';

  @override
  String get selectSigningCertificateTitle => 'Nastavenie certifikátu';

  @override
  String get selectSigningCertificateBody => 'Na podpisovanie mobilom potrebujete disponovať vhodným podpisovým certifikátom. Podpisový certifikát si môžete nastaviť aj neskôr počas podpisovania prvého dokumentu.\n\n\nAk si prajete nastaviť podpisový certifikát teraz, pripravte si, prosím, občiansky preukaz a nasledujte inštrukcie na obrazovke.';

  @override
  String get selectSigningCertificateCanceledHeading => 'Čítanie certifikátu bolo prerušené';

  @override
  String get selectSigningCertificateCanceledBody => 'Skúste prosím znovu načítať certifikát z vášho občianskeho preukazu.';

  @override
  String get selectSigningCertificateNoCertificateHeading => 'Certifikát nebol nájdený';

  @override
  String get selectSigningCertificateNoCertificateBody => 'Nepodarilo sa nájsť certifikát pre kvalifikovaný elektronický podpis.\n\nCertifikát je potrebné vydať v aplikácii eID klient, prípadne použiť iný občiansky preukaz.\nNávod na vydanie certifikátu nájdete na ';

  @override
  String get selectSigningCertificateNoCertificateGuideUrl => 'https://navody.digital/zivotne-situacie/aktivacia-eid/krok/certifikaty';

  @override
  String get selectSigningCertificateErrorHeading => 'Chyba pri načítavaní certifikátov z občianskeho preukazu.';

  @override
  String certificateIssuer(Object text) {
    return 'Vydavateľ: $text';
  }

  @override
  String certificateNotAfter(Object text) {
    return 'Platný do: $text';
  }

  @override
  String get signDocumentTitle => 'Podpisovanie dokumentu';

  @override
  String get signDocumentCanceledHeading => 'Podpisovanie pomocou občianskeho preukazu bolo prerušené';

  @override
  String get signDocumentErrorHeading => 'Pri podpisovaní sa vyskytla chyba';

  @override
  String get documentSigningSuccessTitle => 'Dokument bol úspešne podpísaný';

  @override
  String get saveSignedDocumentSuccessMessage => 'Dokument bol uložený do Downloads pod názvom ';

  @override
  String saveSignedDocumentErrorMessage(Object error) {
    return 'Pri ukladaní súboru sa vyskytla chyba:\n$error';
  }

  @override
  String get shareSignedDocumentLabel => 'Zdieľať podpísaný dokument';

  @override
  String get shareSignedDocumentSubject => 'Elektronicky podpísaný dokument';

  @override
  String get shareSignedDocumentText => '\n\nPodpísané aplikáciou Autogram v mobile';

  @override
  String shareSignedDocumentErrorMessage(Object error) {
    return 'Pri zdieľaní súboru sa vyskytla chyba:\n$error';
  }

  @override
  String get empty => '';
}
