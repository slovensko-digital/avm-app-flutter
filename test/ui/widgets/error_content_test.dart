import 'package:autogram/l10n/app_localizations.dart';
import 'package:autogram/ui/widgets/error_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [ErrorContent] widget.
void main() {
  /// Helper to wrap ErrorContent with necessary MaterialApp context
  Widget buildTestWidget({
    required ErrorContent child,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('ErrorContent', () {
    testWidgets('displays title and error message', (WidgetTester tester) async {
      final testError = Exception('Test error message');
      final errorContent = ErrorContent(
        title: 'Test Error Title',
        error: testError,
      );

      await tester.pumpWidget(buildTestWidget(child: errorContent));

      expect(find.text('Test Error Title'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('displays danger icon for error', (WidgetTester tester) async {
      final errorContent = ErrorContent(
        title: 'Error Title',
        error: Exception('Error'),
      );

      await tester.pumpWidget(buildTestWidget(child: errorContent));

      // Check if the danger icon SVG is loaded
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('displays action button when provided', (WidgetTester tester) async {
      bool buttonPressed = false;

      final errorContent = ErrorContent(
        title: 'Error Title',
        error: Exception('Error'),
        actionButtonLabel: 'Try Again',
        onActionPressed: () {
          buttonPressed = true;
        },
      );

      await tester.pumpWidget(buildTestWidget(child: errorContent));

      expect(find.text('Try Again'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      expect(buttonPressed, isTrue);
    });

    testWidgets('does not display button when only label is provided', (WidgetTester tester) async {
      final errorContent = ErrorContent(
        title: 'Error Title',
        error: Exception('Error'),
        actionButtonLabel: 'Try Again',
        onActionPressed: null,
      );

      await tester.pumpWidget(buildTestWidget(child: errorContent));

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('does not display button when only callback is provided', (WidgetTester tester) async {
      final errorContent = ErrorContent(
        title: 'Error Title',
        error: Exception('Error'),
        actionButtonLabel: null,
        onActionPressed: () {},
      );

      await tester.pumpWidget(buildTestWidget(child: errorContent));

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('content is scrollable on small screens', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 600);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final errorContent = ErrorContent(
        title: 'Error Title',
        error: Exception('This is a very long error message that might cause scrolling issues on small screens'),
        actionButtonLabel: 'Try Again',
        onActionPressed: () {},
      );

      await tester.pumpWidget(buildTestWidget(child: errorContent));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('handles different error types', (WidgetTester tester) async {
      final errorContent = ErrorContent(
        title: 'Error Title',
        error: 'String error',
      );

      await tester.pumpWidget(buildTestWidget(child: errorContent));

      expect(find.byType(Text), findsWidgets);
    });
  });
}
