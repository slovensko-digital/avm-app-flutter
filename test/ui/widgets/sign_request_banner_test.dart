import 'package:autogram/l10n/app_localizations.dart';
import 'package:autogram/l10n/app_localizations_sk.dart';
import 'package:autogram/ui/app_theme.dart';
import 'package:autogram/ui/widgets/sign_request_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [signRequestBanner].
void main() {
  final strings = AppLocalizationsSk();
  late int opened;
  late int dismissed;

  setUp(() {
    opened = 0;
    dismissed = 0;
  });

  Widget host({double textScale = 1}) {
    return Builder(
      builder: (context) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: appTheme(context, brightness: Brightness.light),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Scaffold(
            appBar: AppBar(title: const Text("Náhľad dokumentu")),
            body: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  Future<void> showBanner(
    WidgetTester tester, {
    Size? size,
    double textScale = 1,
  }) async {
    if (size != null) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    await tester.pumpWidget(host(textScale: textScale));

    final context = tester.element(find.byType(Scaffold));

    ScaffoldMessenger.of(context).showMaterialBanner(
      signRequestBanner(
        context,
        onOpenPressed: () => opened++,
        onDismissPressed: () => dismissed++,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('has title, message and both actions', (tester) async {
    await showBanner(tester);

    expect(find.text(strings.newSignRequestTitle), findsOneWidget);
    expect(find.text(strings.newSignRequestMessage), findsOneWidget);

    await tester.tap(find.text(strings.openSignRequestLabel));
    await tester.tap(find.byTooltip(strings.buttonCloseLabel));
    expect(opened, 1);
    expect(dismissed, 1);
  });

  TextStyle textStyle(WidgetTester tester, String text) {
    return tester.renderObject<RenderParagraph>(find.text(text)).text.style!;
  }

  test('has short title', () {
    expect(strings.newSignRequestTitle, "Nová žiadosť o podpis");
  });

  testWidgets('is dark strip as the main app bar', (tester) async {
    await showBanner(tester);

    final banner = tester.widget<MaterialBanner>(find.byType(MaterialBanner));
    final title = textStyle(tester, strings.newSignRequestTitle);

    expect(banner.backgroundColor, kMainAppBarBackgroundColor);
    expect(title.color, kMainAppBarForegroundColor);
    expect(title.fontWeight, FontWeight.bold);
    expect(
      textStyle(tester, strings.newSignRequestMessage).color,
      const Color(0xFFC3D9F9),
    );
    expect(
      find.widgetWithText(OutlinedButton, strings.openSignRequestLabel),
      findsOneWidget,
    );
  });

  testWidgets('has bold Otvoriť as other buttons', (tester) async {
    await showBanner(tester);

    final label = textStyle(tester, strings.openSignRequestLabel);
    expect(label.fontWeight, FontWeight.bold);
    expect(label.letterSpacing, 1.2);
  });

  testWidgets('has actions beside text', (tester) async {
    await showBanner(tester);

    expect(
      tester.getTopLeft(find.text(strings.openSignRequestLabel)).dy,
      lessThan(
        tester.getBottomLeft(find.text(strings.newSignRequestMessage)).dy,
      ),
    );
  });

  testWidgets('has space around text beside actions', (tester) async {
    await showBanner(tester);

    final banner = tester.getRect(find.byType(MaterialBanner));
    expect(
      banner.bottom -
          tester.getBottomLeft(find.text(strings.newSignRequestMessage)).dy,
      greaterThanOrEqualTo(8),
    );
    expect(
      tester.getTopLeft(find.text(strings.newSignRequestTitle)).dy - banner.top,
      greaterThanOrEqualTo(8),
    );
  });

  testWidgets('puts actions below text with large font', (tester) async {
    await showBanner(tester, size: const Size(412, 915), textScale: 2);

    expect(
      tester.getTopLeft(find.text(strings.openSignRequestLabel)).dy,
      greaterThan(
        tester.getBottomLeft(find.text(strings.newSignRequestMessage)).dy,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('has actions beside text on 393 px phone', (tester) async {
    await showBanner(tester, size: const Size(393, 852));

    expect(
      tester.getTopLeft(find.text(strings.openSignRequestLabel)).dy,
      lessThan(
        tester.getBottomLeft(find.text(strings.newSignRequestMessage)).dy,
      ),
    );
  });

  testWidgets('puts actions below text on narrow phone', (tester) async {
    await showBanner(tester, size: const Size(360, 640));

    expect(
      tester.getTopLeft(find.text(strings.openSignRequestLabel)).dy,
      greaterThan(
        tester.getBottomLeft(find.text(strings.newSignRequestMessage)).dy,
      ),
    );
  });

  testWidgets('fits narrow screen', (tester) async {
    await showBanner(tester, size: const Size(320, 640));

    expect(tester.takeException(), isNull);
  });

  testWidgets('is announced by screen readers', (tester) async {
    final semantics = tester.ensureSemantics();

    await showBanner(tester);

    expect(
      tester.getSemantics(
        find.bySemanticsLabel(RegExp(strings.newSignRequestTitle)),
      ),
      isSemantics(
        label:
            "${strings.newSignRequestTitle}\n${strings.newSignRequestMessage}",
        isLiveRegion: true,
      ),
    );

    semantics.dispose();
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final semantics = tester.ensureSemantics();

    await showBanner(tester);

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    semantics.dispose();
  });
}
