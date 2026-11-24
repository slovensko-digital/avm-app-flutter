import 'package:flutter/foundation.dart' show kIsWeb;
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
    final addons = <WidgetbookAddon>[
      if (kIsWeb)
        ViewportAddon(
          [
            ...IosViewports.phones,
            ...AndroidViewports.phones,
          ],
        ),
      if (kIsWeb)
        BuilderAddon(
          name: "SafeArea",
          builder: (context, child) {
            // Needed to wrap each child when using DeviceFrameAddon
            return SafeArea(child: child);
          },
        ),
      TextScaleAddon(),
    ];

    return Widgetbook.material(
      directories: directories,
      addons: addons,
      themeMode: ThemeMode.light,
      appBuilder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // the app supports only light theme, see App
          theme: appTheme(context, brightness: Brightness.light),
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
