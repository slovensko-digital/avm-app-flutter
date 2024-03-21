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
    final themes = [
      for (final brightness in Brightness.values)
        WidgetbookTheme(
          name: brightness.name,
          data: appTheme(context, brightness: brightness),
        )
    ];
    final initialTheme =
        themes.singleWhere((e) => e.name == Brightness.light.name);

    final addons = <WidgetbookAddon>[
      if (kIsWeb)
        DeviceFrameAddon(
          devices: [
            Devices.ios.iPhoneSE,
            Devices.ios.iPhone13,
            Devices.ios.iPhone13ProMax,
            Devices.android.smallPhone.copyWith(name: "360×640dp"),
            Devices.android.mediumPhone.copyWith(name: "412×732dp"),
          ],
          initialDevice: Devices.ios.iPhone13,
        ),
      if (kIsWeb)
        BuilderAddon(
          name: "SafeArea",
          builder: (context, child) {
            // Needed to wrap each child when using DeviceFrameAddon
            return SafeArea(child: child);
          },
        ),
      MaterialThemeAddon(
        themes: themes,
        initialTheme: initialTheme,
      ),
    ];

    return Widgetbook.material(
      directories: directories,
      addons: addons,
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
