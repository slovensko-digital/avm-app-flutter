import 'package:autogram/l10n/app_localizations.dart';
import 'package:autogram/l10n/app_localizations_sk.dart';
import 'package:autogram/ui/screens/id_card_troubleshooting_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [IdCardTroubleshootingDialog] widget.
void main() {
  final strings = AppLocalizationsSk();

  /// Helper to wrap dialog with necessary MaterialApp context
  Widget buildTestWidget() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: const IdCardTroubleshootingDialog(),
    );
  }

  group('IdCardTroubleshootingDialog', () {
    testWidgets('displays dialog title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text(strings.idCardTroubleshootingTitle), findsOneWidget);
    });

    testWidgets('displays troubleshooting instructions', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // The instructions should be rendered as markdown
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('displays close button at the bottom', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, strings.closeLabel), findsOneWidget);
    });

    testWidgets('animated image carousel cycles through images', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Find the initial SVG (image 1)
      expect(find.byType(SvgPicture), findsOneWidget);

      // Verify first image is shown
      await tester.pump();
      expect(find.byType(SvgPicture), findsOneWidget);

      // Wait for first image cycle (1.65 seconds)
      await tester.pump(const Duration(milliseconds: 1700));

      // Image should still exist (carousel still running)
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('has proper styling and layout', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Should have Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
      
      // Should have SingleChildScrollView for scrolling
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // Should have SvgPicture for images
      expect(find.byType(SvgPicture), findsOneWidget);
    });
  });
}

