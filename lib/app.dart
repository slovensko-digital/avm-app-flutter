import 'package:flutter/material.dart';

import 'ui/app_theme.dart';
import 'ui/screens/main_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autogram',
      debugShowCheckedModeBanner: false,
      theme: appTheme(context, brightness: Brightness.light),
      home: const MainScreen(),
    );
  }
}
