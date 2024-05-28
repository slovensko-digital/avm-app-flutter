import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_navigator_observer.dart';
import 'app_service.dart';
import 'bloc/app_bloc.dart';
import 'di.dart';
import 'l10n/app_localizations.dart';
import 'strings_context.dart';
import 'ui/app_theme.dart';
import 'ui/screens/main_screen.dart';

/// Main Material app.
///
/// Gets [AppService] to read its [AppService.incomingUri].
///
/// Home is [MainScreen].
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appService = getIt.get<AppService>();

    final home = ValueListenableBuilder(
      valueListenable: appService.incomingUri,
      builder: (context, incomingUri, _) {
        // TODO Convert to stateful and show modal dialog with question whether to start over with different input file

        return MainScreen(
          incomingUri: incomingUri,
        );
      },
    );

    final app = MaterialApp(
      title: context.strings.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [AppNavigatorObserver()],
      theme: appTheme(context, brightness: Brightness.light),
      home: home,
    );

    return BlocProvider<AppBloc>(
      create: (_) => AppBloc(),
      child: app,
    );
  }
}
