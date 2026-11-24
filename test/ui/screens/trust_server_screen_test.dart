import 'package:autogram/data/avm_server.dart';
import 'package:autogram/l10n/app_localizations.dart';
import 'package:autogram/l10n/app_localizations_sk.dart';
import 'package:autogram/ui/app_theme.dart';
import 'package:autogram/ui/screens/trust_server_screen.dart';
import 'package:autogram/ui/widgets/notification_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [TrustServerScreen].
void main() {
  final strings = AppLocalizationsSk();

  /// The app with its theme - see App.
  Widget host() => Builder(
    builder: (context) => MaterialApp(
      theme: appTheme(context, brightness: Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const TrustServerScreen(
        server: AvmServer("avm.example.org"),
        next: SizedBox(),
      ),
    ),
  );

  TextStyle textStyle(WidgetTester tester, String text) {
    return tester.renderObject<RenderParagraph>(find.text(text)).text.style!;
  }

  /// WCAG 2 contrast ratio.
  double contrast(Color a, Color b) {
    final [lighter, darker] = [
      a.computeLuminance(),
      b.computeLuminance(),
    ]..sort((x, y) => y.compareTo(x));

    return (lighter + 0.05) / (darker + 0.05);
  }

  testWidgets('warns in ID-SK banner, that the server is not official', (
    tester,
  ) async {
    await tester.pumpWidget(host());

    final banner = find.byType(NotificationBanner);
    expect(
      find.descendant(
        of: banner,
        matching: find.text("Dokument poskytuje avm.example.org"),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: banner,
        matching: find.text(
          strings.trustServerNotOfficialLabel(AvmServer.official.authority),
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('document types info is as big as the text above', (
    tester,
  ) async {
    await tester.pumpWidget(host());

    final info = textStyle(tester, strings.trustServerDocumentTypesInfo);
    final above = textStyle(
      tester,
      "${strings.trustServerVerifiedInfo} "
      "${strings.trustServerNotVerifiedInfo}",
    );

    expect(info.fontSize, above.fontSize);
  });

  testWidgets('document types info has WCAG AA contrast', (tester) async {
    await tester.pumpWidget(host());

    final info = textStyle(tester, strings.trustServerDocumentTypesInfo);
    final background = Theme.of(
      tester.element(find.byType(Scaffold)),
    ).scaffoldBackgroundColor;

    expect(contrast(info.color!, background), greaterThanOrEqualTo(4.5));
  });
}
