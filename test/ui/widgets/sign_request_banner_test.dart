import 'package:autogram/l10n/app_localizations.dart';
import 'package:autogram/l10n/app_localizations_sk.dart';
import 'package:autogram/ui/app_theme.dart';
import 'package:autogram/ui/widgets/sign_request_banner.dart';
import 'package:flutter/material.dart';
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

  Widget host() {
    return Builder(
      builder: (context) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: appTheme(context, brightness: Brightness.light),
          home: Scaffold(
            appBar: AppBar(title: const Text("Náhľad dokumentu")),
            body: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  Future<void> showBanner(WidgetTester tester) async {
    await tester.pumpWidget(host());

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
    await tester.tap(find.text(strings.buttonCloseLabel));
    expect(opened, 1);
    expect(dismissed, 1);
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
