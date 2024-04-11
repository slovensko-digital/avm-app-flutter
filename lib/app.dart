import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_service.dart';
import 'ui/app_theme.dart';
import 'ui/screens/main_screen.dart';

/// Main Material app.
///
/// Consumes [AppService] to read its [AppService.sharedFile].
///
/// Home is [MainScreen].
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(
      builder: (context, appService, _) {
        return ValueListenableBuilder(
          valueListenable: appService.sharedFile,
          builder: (context, sharedFile, _) {
            // TODO Rewrite this to StatefulWidget and show modal dialog whether to start over
            // It's like this just for dev purposes of iOS app

            return _buildBody(context, sharedFile);
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, Uri? sharedFile) {
    return MaterialApp(
      title: 'Autogram',
      debugShowCheckedModeBanner: false,
      theme: appTheme(context, brightness: Brightness.light),
      home: MainScreen(
        sharedFile: sharedFile,
      ),
    );
  }
}
