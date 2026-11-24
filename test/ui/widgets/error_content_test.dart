import 'package:autogram/l10n/app_localizations.dart';
import 'package:autogram/l10n/app_localizations_sk.dart';
import 'package:autogram/ui/widgets/error_content.dart';
import 'package:autogram/verification/document_verification_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [ErrorContent].
void main() {
  final strings = AppLocalizationsSk();

  Widget host(Object error) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ErrorContent(title: "Chyba", error: error),
    ),
  );

  Finder icon(String asset) => find.byWidgetPredicate(
    (widget) =>
        widget is SvgPicture &&
        widget.bytesLoader is SvgAssetLoader &&
        (widget.bytesLoader as SvgAssetLoader).assetName == asset,
  );

  testWidgets('shows document mismatch icon when data to sign mismatch', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const DocumentVerificationException(
          DocumentVerificationFailure.dataToSignMismatch,
          "Digest doesn't match.",
        ),
      ),
    );

    expect(icon('assets/images/document_mismatch.svg'), findsOneWidget);
    expect(icon('assets/images/danger.svg'), findsNothing);
    expect(
      find.text(strings.documentVerificationDataToSignMismatchError),
      findsOneWidget,
    );
  });

  testWidgets('shows document mismatch icon when local document mismatch', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const DocumentVerificationException(
          DocumentVerificationFailure.localDocumentMismatch,
          "Not the selected file.",
        ),
      ),
    );

    expect(icon('assets/images/document_mismatch.svg'), findsOneWidget);
  });

  testWidgets('shows danger icon for other errors', (tester) async {
    await tester.pumpWidget(host(Exception("Network error")));

    expect(icon('assets/images/danger.svg'), findsOneWidget);
    expect(icon('assets/images/document_mismatch.svg'), findsNothing);
  });
}
