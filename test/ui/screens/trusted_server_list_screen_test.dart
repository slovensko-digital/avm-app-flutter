import 'package:autogram/data/settings.dart';
import 'package:autogram/l10n/app_localizations.dart';
import 'package:autogram/l10n/app_localizations_sk.dart';
import 'package:autogram/ui/screens/trusted_server_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:provider/provider.dart';

/// Tests for the [TrustedServerListScreen].
void main() {
  final strings = AppLocalizationsSk();
  late Settings settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = await Settings.create();
  });

  Widget host() => Provider<Settings>.value(
    value: settings,
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: TrustedServerListScreen(),
    ),
  );

  testWidgets('shows empty list', (tester) async {
    await tester.pumpWidget(host());

    expect(find.text(strings.trustedServersEmpty), findsOneWidget);
  });

  testWidgets('removes trusted server', (tester) async {
    settings.trustedServers.value = ['avm.example.org', 'podpis.example.sk'];
    await tester.pumpWidget(host());

    expect(find.text('avm.example.org'), findsOneWidget);
    expect(find.text('podpis.example.sk'), findsOneWidget);

    await tester.tap(find.byTooltip(strings.trustedServerDeleteTooltip).first);
    await tester.pumpAndSettle();

    expect(find.text('avm.example.org'), findsNothing);
    expect(settings.trustedServers.value, ['podpis.example.sk']);

    await tester.tap(find.byTooltip(strings.trustedServerDeleteTooltip));
    await tester.pumpAndSettle();

    expect(find.text(strings.trustedServersEmpty), findsOneWidget);
    expect(settings.trustedServers.value, isEmpty);
  });
}
