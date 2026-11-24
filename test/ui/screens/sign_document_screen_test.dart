import 'package:autogram/bloc/sign_document_cubit.dart';
import 'package:autogram/data/document_signing_type.dart';
import 'package:autogram/data/document_to_sign.dart';
import 'package:autogram/data/signature_type.dart';
import 'package:autogram/l10n/app_localizations.dart';
import 'package:autogram/l10n/app_localizations_sk.dart';
import 'package:autogram/services/autogram_services.dart';
import 'package:autogram/ui/screens/sign_document_screen.dart';
import 'package:autogram/verification/document_verification_exception.dart';
import 'package:autogram_sign/autogram_sign.dart';
import 'package:eidmsdk/eidmsdk.dart';
import 'package:eidmsdk/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

const _certificate = Certificate(
  slot: "1",
  supportedSchemes: [],
  isQualified: true,
  certIndex: 1,
  certData: "certificate",
);

const _document = DocumentToSign(
  "1",
  visualization: VerifiableVisualizationResponseBody(
    signatureForm: VerifiableVisualizationResponseBodySignatureForm.xades,
    document: SignedDataObject(
      filename: "platba.txt",
      mimeType: "text/plain;base64",
      content: "",
    ),
  ),
);

/// Tests for the [SignDocumentScreen].
void main() {
  final strings = AppLocalizationsSk();
  final getIt = GetIt.instance;

  tearDown(() => getIt.reset());

  void signingFailsWith(Object error) {
    getIt.registerFactoryParam<SignDocumentCubit, DocumentToSign, Certificate>(
      (document, certificate) => _FailingCubit(document, certificate, error),
    );
  }

  /// Main screen, which opens [SignDocumentScreen] over other screen - as the
  /// certificate selection.
  Widget host() => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Column(
          children: [
            const Text("Hlavná obrazovka"),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await navigator.push(
                  MaterialPageRoute(
                    builder: (_) => const Scaffold(body: Text("Certifikát")),
                  ),
                );
              },
              child: const Text("Otvoriť"),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> openSignDocumentScreen(WidgetTester tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text("Otvoriť"));
    await tester.pumpAndSettle();

    final context = tester.element(find.text("Certifikát"));
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SignDocumentScreen(
          document: _document,
          certificate: _certificate,
          signatureType: SignatureType.withoutTimestamp,
          signingType: DocumentSigningType.remote,
          openFromDeepLink: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('cancels signing of mismatching document', (tester) async {
    signingFailsWith(
      const DocumentVerificationException(
        DocumentVerificationFailure.dataToSignMismatch,
        "Digest doesn't match.",
      ),
    );
    await openSignDocumentScreen(tester);

    expect(
      find.text(strings.documentVerificationDataToSignMismatchError),
      findsOneWidget,
    );

    // secondary button - as "Zavrieť" after signing
    await tester.tap(
      find.widgetWithText(TextButton, strings.buttonCancelLabel),
    );
    await tester.pumpAndSettle();

    // back on the main screen, not on the certificate selection
    expect(find.text("Hlavná obrazovka"), findsOneWidget);
    expect(find.text("Certifikát"), findsNothing);
    expect(find.byType(SignDocumentScreen), findsNothing);
  });

  testWidgets('shows no cancel button for other errors', (tester) async {
    signingFailsWith(Exception("Network error"));
    await openSignDocumentScreen(tester);

    expect(find.text(strings.buttonCancelLabel), findsNothing);
  });
}

/// [SignDocumentCubit], which fails to sign with the [error].
class _FailingCubit extends SignDocumentCubit {
  final Object error;

  _FailingCubit(DocumentToSign document, Certificate certificate, this.error)
    : super(
        services: _Services(),
        eidmsdk: _Eidmsdk(),
        document: document,
        certificate: certificate,
      );

  @override
  Future<void> signDocument(SignatureType signatureType) async {
    emit(SignDocumentErrorState(error));
  }
}

class _Services extends Fake implements AutogramServices {}

class _Eidmsdk extends Fake implements Eidmsdk {}
