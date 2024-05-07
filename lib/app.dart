import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_navigator_observer.dart';
import 'app_service.dart';
import 'l10n/app_localizations.dart';
import 'strings_context.dart';
import 'ui/app_theme.dart';
import 'ui/screens/main_screen.dart';

/// Main Material app.
///
/// Consumes [AppService] to read its [AppService.incomingUri].
///
/// Home is [MainScreen].
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO Move "Consumer<AppService>" and additional code into MainScreen
    final home = Consumer<AppService>(
      builder: (context, appService, _) {
        return ValueListenableBuilder(
          valueListenable: appService.incomingUri,
          builder: (context, incomingUri, _) {
            // TODO Convert to stateful and show modal dialog with question whether to start over with different input file

            return MainScreen(
              incomingUri: incomingUri,
            );
          },
        );
      },
    );

    return MaterialApp(
      title: context.strings.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [AppNavigatorObserver()],
      theme: appTheme(context, brightness: Brightness.light),

      // Normally, setting home Widget would be sufficient
      // However need to assign arguments to RouteSettings so it can be read
      // back when navigated from OnboardingScreen
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            // ignore: prefer_const_constructors, prefer_const_literals_to_create_immutables
            settings: RouteSettings(name: '/', arguments: {}),
            builder: (_) => home,
          );
        }

        return null;
      },
    );
  }
}
