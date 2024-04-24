import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Displays app version, e.g.: "1.0.0(1)".
class AppVersionText extends HookWidget {
  final TextStyle? textStyle;

  const AppVersionText({super.key, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final future = useMemoized(() => PackageInfo.fromPlatform());
    final pi = useFuture(future).data;
    final appVersion = (pi != null ? "${pi.version}(${pi.buildNumber})" : null);

    return Text(
      appVersion ?? '',
      textAlign: TextAlign.center,
      style: textStyle ?? Theme.of(context).textTheme.bodyLarge,
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: '',
  type: AppVersionText,
)
Widget previewAppVersionText(BuildContext context) {
  return const AppVersionText();
}
