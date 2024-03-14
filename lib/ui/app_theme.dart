import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Screen margin.
const EdgeInsets kScreenMargin = EdgeInsets.all(16);

/// Primary button minimum size.
const Size kPrimaryButtonMinimumSize = Size.fromHeight(60);

/// Main [AppBar.backgroundColor] value.
const kMainAppBarBackgroundColor = Color(0xFF072C66);

/// Main [AppBar.foregroundColor] value.
const kMainAppBarForegroundColor = Color(0xFFFFFFFF);

/// [Radio.activeColor] value.
const kRadioActiveColor = Colors.black;

/// [Radio] scale factor to default size.
const kRadioScale = 1.66;

/// Returns M3 [ThemeData].
ThemeData appTheme(
  BuildContext context, {
  Brightness? brightness,
}) {
  const color = Color(0xFF126DFF);
  final colorScheme = ColorScheme.fromSeed(
    brightness: brightness ?? MediaQuery.platformBrightnessOf(context),
    seedColor: color,
  );
  final textTheme = Theme.of(context).textTheme.apply(
        fontSizeFactor: 1.2,
      );
  final appBarTheme = AppBarTheme(
    titleTextStyle: TextStyle(
      color: colorScheme.onBackground,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  );
  final dialogTheme = DialogTheme(
    surfaceTintColor: colorScheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
  );

  return ThemeData(
    useMaterial3: true,
    primaryColor: color,
    colorScheme: colorScheme,
    fontFamily: "Source Sans 3",
    // see /assets/fonts
    textTheme: textTheme,
    appBarTheme: appBarTheme,
    dialogTheme: dialogTheme,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
    // radioTheme: not set
  );
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'normal',
  type: AppBar,
)
Widget previewAppBar(BuildContext context) {
  return SizedBox(
    height: kToolbarHeight,
    child: AppBar(
      leading: const BackButton(),
      title: const Text("Náhľad dokumentu"),
    ),
  );
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'Radio',
  type: Radio,
)
Widget previewRadio(BuildContext context) {
  int selectedValue = 0;

  return StatefulBuilder(builder: (context, setState) {
    Widget customRadio({
      required int value,
      bool enabled = true,
    }) {
      return Transform.scale(
        scale: kRadioScale,
        child: Radio<int>(
          value: value,
          groupValue: selectedValue,
          activeColor: kRadioActiveColor,
          onChanged: enabled
              ? (value) {
                  if (value != null) {
                    setState(() => selectedValue = value);
                  }
                }
              : null,
        ),
      );
    }

    return ButtonBar(
      alignment: MainAxisAlignment.start,
      children: [
        customRadio(
          value: 0,
        ),
        customRadio(
          value: 1,
        ),
        customRadio(
          value: 0,
          enabled: false,
        ),
        customRadio(
          value: 1,
          enabled: false,
        ),
      ],
    );
  });
}
