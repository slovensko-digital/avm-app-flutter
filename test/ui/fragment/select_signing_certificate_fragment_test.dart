import 'package:autogram/bloc/select_signing_certificate_state.dart';
import 'package:autogram/l10n/app_localizations.dart';
import 'package:autogram/l10n/app_localizations_sk.dart';
import 'package:autogram/ui/fragment/select_signing_certificate_fragment.dart';
import 'package:autogram/ui/screens/id_card_troubleshooting_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [SelectSigningCertificateFragment] widget with error handling.
void main() {
  final strings = AppLocalizationsSk();

  /// Helper to wrap fragment with necessary MaterialApp context
  Widget buildTestWidget({
    required SelectSigningCertificateState state,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SelectSigningCertificateFragment(
          state: state,
          successBuilder: (context, certificate) {
            return const Text('Certificate Loaded Successfully');
          },
        ),
      ),
    );
  }

  group('SelectSigningCertificateFragment', () {
    testWidgets('displays error content with troubleshooting button on error state',
        (WidgetTester tester) async {
      final testError = Exception('Failed to read certificate');
      final errorState = SelectSigningCertificateErrorState(testError);

      await tester.pumpWidget(buildTestWidget(state: errorState));

      expect(find.text(strings.selectSigningCertificateErrorHeading), findsOneWidget);
      expect(find.text('Failed to read certificate'), findsOneWidget);
      expect(find.text(strings.troubleshootingButtonLabel), findsOneWidget);
    });

    testWidgets('opens troubleshooting dialog when button is tapped',
        (WidgetTester tester) async {
      final testError = Exception('Failed to read certificate');
      final errorState = SelectSigningCertificateErrorState(testError);

      await tester.pumpWidget(buildTestWidget(state: errorState));

      // Initially dialog should not be visible
      expect(find.byType(IdCardTroubleshootingDialog), findsNothing);

      // Tap the troubleshooting button
      await tester.tap(find.text(strings.troubleshootingButtonLabel));
      // Use pump instead of pumpAndSettle because the dialog has continuous animation
      await tester.pump(const Duration(milliseconds: 400));

      // Dialog should now be visible
      expect(find.byType(IdCardTroubleshootingDialog), findsOneWidget);
      expect(find.text(strings.idCardTroubleshootingTitle), findsOneWidget);
      // Verify the dialog has the carousel image (280x280 from Scaffold)
      expect(find.byWidgetPredicate(
        (widget) => widget is SvgPicture && widget.width == 280 && widget.height == 280,
      ), findsOneWidget);
    });

    testWidgets('dialog displays close button and instructions',
        (WidgetTester tester) async {
      final testError = Exception('Failed to read certificate');
      final errorState = SelectSigningCertificateErrorState(testError);

      await tester.pumpWidget(buildTestWidget(state: errorState));

      // Open dialog
      await tester.tap(find.text(strings.troubleshootingButtonLabel));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(IdCardTroubleshootingDialog), findsOneWidget);

      // Verify close button is present
      expect(find.widgetWithText(ElevatedButton, strings.closeLabel), findsOneWidget);
      
      // Verify title is visible
      expect(find.text(strings.idCardTroubleshootingTitle), findsOneWidget);
    });

    testWidgets('displays different error messages for different errors',
        (WidgetTester tester) async {
      final errorState = SelectSigningCertificateErrorState(
        Exception('NFC read timeout'),
      );

      await tester.pumpWidget(buildTestWidget(state: errorState));

      expect(find.text('NFC read timeout'), findsOneWidget);
    });

    testWidgets('error screen content is scrollable', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 600);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final errorState = SelectSigningCertificateErrorState(
        Exception('A very long error message that might cause scrolling issues on small screens'),
      );

      await tester.pumpWidget(buildTestWidget(state: errorState));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
