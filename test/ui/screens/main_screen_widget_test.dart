import 'package:autogram/bloc/app_bloc.dart';
import 'package:autogram/data/settings.dart';
import 'package:autogram/l10n/app_localizations.dart';
import 'package:autogram/l10n/app_localizations_sk.dart';
import 'package:autogram/ui/app_theme.dart';
import 'package:autogram/ui/screens/main_screen.dart';
import 'package:autogram/ui/widgets/autogram_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:provider/provider.dart';

/// Tests for the [MainScreen] widget.
void main() async {
  late Settings settings;
  late Widget widget;
  final strings = AppLocalizationsSk();

  /// Setup before each test.
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    settings = await Settings.create(await SharedPreferences.getInstance());

    TestWidgetsFlutterBinding.ensureInitialized();

    widget = MultiProvider(
      providers: [
        Provider<Settings>.value(value: settings),
        Provider<AppBloc>.value(value: AppBloc()),
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          theme: appTheme(context, brightness: Brightness.light),
          home: const MainScreen(),
        );
      }),
    );
  });

  testWidgets('MainScreen has AppBar, logo, heading and body text',
      (tester) async {
    await tester.pumpWidget(widget);

    final AppBar appBar = tester.widget(find.byType(AppBar));

    expect(appBar, isNotNull);
    expect(appBar.leading, isNotNull);
    expect(appBar.title, isNotNull);

    expect(find.byType(AutogramLogo), findsOneWidget);
    expect(find.text(strings.introHeading), findsOneWidget);
    expect(find.text(strings.introBody), findsOneWidget);
  });

  testWidgets(
      'MainScreen has only "Setup" button visible when Onboarding was not finished',
      (tester) async {
    await tester.pumpWidget(widget);

    expect(find.text(strings.buttonInitialSetupLabel), findsOneWidget);
  });

  testWidgets('MainScreen has two buttons visible when Onboarding was finished',
      (tester) async {
    settings.acceptedPrivacyPolicyVersion.value = "1";
    settings.acceptedTermsOfServiceVersion.value = "1";

    await tester.pumpWidget(widget);

    expect(find.text(strings.buttonInitialSetupLabel), findsNothing);
    expect(find.text(strings.buttonScanQrCodeLabel), findsOneWidget);
    expect(find.text(strings.buttonOpenDocumentLabel), findsOneWidget);
  });

  testWidgets('MainScreen has two buttons visible when Onboarding was finished',
      (tester) async {
    settings.acceptedPrivacyPolicyVersion.value = "1";
    settings.acceptedTermsOfServiceVersion.value = "1";

    await tester.pumpWidget(widget);

    expect(find.text(strings.buttonInitialSetupLabel), findsNothing);
    expect(find.text(strings.buttonScanQrCodeLabel), findsOneWidget);
    expect(find.text(strings.buttonOpenDocumentLabel), findsOneWidget);
  });
}
