import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// ID-SK 3 "Informačná lišta" (Notification banner) of "Upozorňovací typ",
/// which "vyžaduje zvýšenú pozornosť používateľa".
///
/// Dimensions and colors are for small screens from
/// https://idsk.gov.sk/komponenty/informacna-lista
///
/// Font sizes are relative as in ID-SK - the [body] is as big as the text
/// around and the [title] is one step larger.
class NotificationBanner extends StatelessWidget {
  static const _color = Color(0xFFBD730C);
  static const _titleColor = Color(0xFF212121);
  static const _bodyColor = Colors.black;

  final Widget title;
  final Widget body;

  const NotificationBanner({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = _style(textTheme.bodyLarge!, height: 1.375).copyWith(
      fontWeight: FontWeight.bold,
      color: _titleColor,
    );
    final bodyStyle = _style(textTheme.bodyMedium!, height: 1.625).copyWith(
      color: _bodyColor,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          left: BorderSide(color: _color, width: 5),
          top: BorderSide(color: _color, width: 2),
          right: BorderSide(color: _color, width: 2),
          bottom: BorderSide(color: _color, width: 2),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        spacing: 12,
        children: [
          SvgPicture.asset(
            'assets/icons/warning.svg',
            width: 24,
            height: 24,
            excludeFromSemantics: true,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Semantics(
                  header: true,
                  child: DefaultTextStyle.merge(
                    style: titleStyle,
                    child: title,
                  ),
                ),
                DefaultTextStyle.merge(
                  style: bodyStyle,
                  child: body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// [style] with line [height] and ID-SK `tracking-wide` letter spacing.
  static TextStyle _style(TextStyle style, {required double height}) {
    return style.copyWith(
      height: height,
      letterSpacing: style.fontSize! * 0.025,
    );
  }
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'NotificationBanner',
  type: NotificationBanner,
)
Widget previewNotificationBanner(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(20),
    child: NotificationBanner(
      title: Text("Dokument poskytuje avm.example.org"),
      body: Text("Nie je to oficiálny server autogram.slovensko.digital."),
    ),
  );
}
