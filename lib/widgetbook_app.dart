import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'app.dart';
import 'ui/app_theme.dart';
import 'widgetbook_app.directories.g.dart';

/// [widgetbook] app
///
/// See also:
///  - [App]
@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themes = [
      for (final brightness in Brightness.values)
        WidgetbookTheme(
          name: brightness.name,
          data: appTheme(context, brightness: brightness),
        )
    ];
    final initialTheme =
        themes.singleWhere((e) => e.name == Brightness.light.name);

    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: themes,
          initialTheme: initialTheme,
        ),
      ],
      appBuilder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appTheme(context),
          home: Scaffold(
            body: SizedBox.expand(
              child: child,
            ),
          ),
        );
      },
    );
  }
}
