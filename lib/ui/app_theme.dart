import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Screen margin.
const EdgeInsets kScreenMargin = EdgeInsets.all(20);

/// Space between two buttons.
const double kButtonSpace = 10;

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
  const primaryColor = Color(0xFF126DFF);
  final colorScheme = ColorScheme.fromSeed(
    brightness: brightness ?? MediaQuery.platformBrightnessOf(context),
    seedColor: primaryColor,
    primary: primaryColor,
  );
  // TODO Consider using Typography.material2021().black.apply(fontSizeFactor: 1.2) so that BuildContext is not needed
  final textTheme = Theme.of(context).textTheme.apply(
        fontSizeFactor: 1.2,
      );
  final appBarTheme = AppBarTheme(
    titleTextStyle: TextStyle(
      color: colorScheme.onSurface,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.15,
    ),
  );
  final dialogTheme = DialogTheme(
    titleTextStyle: TextStyle(
      color: colorScheme.onSurface,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.15,
    ),
    surfaceTintColor: colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  );
  const bottomSheetTheme = BottomSheetThemeData(
    //surfaceTintColor: colorScheme.background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
  );
  const buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  const buttonTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  return ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    colorScheme: colorScheme,
    fontFamily: "Source Sans 3",
    // see /assets/fonts
    textTheme: textTheme,
    appBarTheme: appBarTheme,
    dialogTheme: dialogTheme,
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
    bottomSheetTheme: bottomSheetTheme,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: buttonShape,
        textStyle: buttonTextStyle,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: buttonTextStyle,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: buttonShape,
        textStyle: buttonTextStyle,
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
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.refresh_outlined),
        ),
      ],
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

    return OverflowBar(
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

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'Dialog',
  type: Dialog,
)
Widget previewDialog(BuildContext context) {
  return Container(
    color: Colors.grey.withOpacity(0.25),
    child: const Dialog(
      child: SizedBox(
        width: 240,
        height: 180,
      ),
    ),
  );
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'SnackBar',
  type: SnackBar,
)
Widget previewSnackBar(BuildContext context) {
  final message = context.knobs.string(
    label: "Message",
    initialValue: "Single line message",
    maxLines: 3,
  );
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    content: Text(
      message,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    ),
    action: SnackBarAction(
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      label: "OK",
    ),
  );

  return Padding(
    padding: kScreenMargin,
    child: ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      },
      child: const Text("Show SnackBar"),
    ),
  );
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'MaterialBanner ',
  type: MaterialBanner,
)
Widget previewMaterialBanner(BuildContext context) {
  final message = context.knobs.string(
    label: "Message",
    initialValue: "Single line message",
    maxLines: 5,
  );
  final banner = MaterialBanner(
    leading: const Icon(Icons.info_outline),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        },
        child: const Text("Close"),
      ),
    ],
  );

  return Padding(
    padding: kScreenMargin,
    child: ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentMaterialBanner()
          ..showMaterialBanner(banner);
      },
      child: const Text("Show Banner"),
    ),
  );
}
