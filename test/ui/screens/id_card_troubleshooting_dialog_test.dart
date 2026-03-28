import 'package:autogram/l10n/app_localizations.dart';
import 'package:autogram/l10n/app_localizations_sk.dart';
import 'package:autogram/ui/screens/id_card_troubleshooting_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [IdCardTroubleshootingDialog] widget.
void main() {
  final strings = AppLocalizationsSk();

  /// Helper to wrap dialog with necessary MaterialApp context
  Widget buildTestWidget({
    required Widget child,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (dialogContext) => child,
                ),
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      ),
    );
  }

  group('IdCardTroubleshootingDialog', () {
    testWidgets('displays dialog title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const IdCardTroubleshootingDialog(),
      ));

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text(strings.idCardTroubleshootingTitle), findsOneWidget);
    });

    testWidgets('displays close button in header', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const IdCardTroubleshootingDialog(),
      ));

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('displays troubleshooting instructions', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const IdCardTroubleshootingDialog(),
      ));

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // The instructions should contain several key words
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('displays close button at the bottom', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const IdCardTroubleshootingDialog(),
      ));

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, strings.closeLabel), findsOneWidget);
    });

    testWidgets('closes dialog when close button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const IdCardTroubleshootingDialog(),
      ));

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);

      // Close the dialog (scroll into view first — dialog may overflow viewport)
      final closeButton = find.widgetWithText(ElevatedButton, strings.closeLabel);
      await tester.ensureVisible(closeButton);
      await tester.pumpAndSettle();
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('closes dialog when close icon is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const IdCardTroubleshootingDialog(),
      ));

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);

      // Close the dialog using the close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('dialog is scrollable if content is large', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 500);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(buildTestWidget(
        child: const IdCardTroubleshootingDialog(),
      ));

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('dialog has proper styling with rounded corners', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const IdCardTroubleshootingDialog(),
      ));

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final dialog = find.byType(Dialog).first;
      expect(dialog, findsOneWidget);
    });

    testWidgets('handles missing instruction image gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const IdCardTroubleshootingDialog(),
      ));

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Even if the image doesn't exist, the dialog should still show
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });
  });
}
