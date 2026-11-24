import 'package:autogram/ui/app_theme.dart';
import 'package:autogram/ui/widgets/notification_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [NotificationBanner] - ID-SK 3 "Informačná lišta",
/// "Upozorňovací typ", see https://idsk.gov.sk/komponenty/informacna-lista
void main() {
  const title = "Dokument poskytuje avm.example.org";
  const body = "Nie je to oficiálny server autogram.slovensko.digital.";
  const yellow = Color(0xFFBD730C);

  /// The app with its theme - see App.
  Widget host() => Builder(
    builder: (context) => MaterialApp(
      theme: appTheme(context, brightness: Brightness.light),
      home: const Scaffold(
        body: NotificationBanner(
          title: Text(title),
          body: Text(body),
        ),
      ),
    ),
  );

  TextStyle textStyle(WidgetTester tester, String text) {
    return tester.renderObject<RenderParagraph>(find.text(text)).text.style!;
  }

  testWidgets('has white background and yellow border, thicker on left', (
    tester,
  ) async {
    await tester.pumpWidget(host());

    final decoration =
        tester
                .widget<Container>(
                  find.descendant(
                    of: find.byType(NotificationBanner),
                    matching: find.byType(Container),
                  ),
                )
                .decoration!
            as BoxDecoration;

    expect(decoration.color, Colors.white);
    expect(
      decoration.border,
      const Border(
        left: BorderSide(color: yellow, width: 5),
        top: BorderSide(color: yellow, width: 2),
        right: BorderSide(color: yellow, width: 2),
        bottom: BorderSide(color: yellow, width: 2),
      ),
    );
    expect(decoration.borderRadius, BorderRadius.circular(6));
  });

  testWidgets('shows 24px warning icon 16px inside the border', (
    tester,
  ) async {
    await tester.pumpWidget(host());

    final banner = tester.getRect(find.byType(NotificationBanner));
    final icon = tester.getRect(find.byType(SvgPicture));

    expect(icon.size, const Size.square(24));
    expect(icon.left - banner.left, 5 + 16);
    // vertically centered
    expect(icon.center.dy, closeTo(banner.center.dy, 0.5));
    // text is 12px from the icon
    expect(tester.getTopLeft(find.text(title)).dx - icon.right, 12);
  });

  testWidgets('title is bold heading, one step larger than body text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host());

    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    final titleStyle = textStyle(tester, title);
    final bodyStyle = textStyle(tester, body);

    expect(tester.getSemantics(find.text(title)), isSemantics(isHeader: true));
    expect(titleStyle.fontWeight, FontWeight.bold);
    expect(titleStyle.color, const Color(0xFF212121));
    expect(titleStyle.fontSize, theme.textTheme.bodyLarge!.fontSize);
    // body as the text around
    expect(bodyStyle.color, Colors.black);
    expect(bodyStyle.fontSize, theme.textTheme.bodyMedium!.fontSize);

    semantics.dispose();
  });
}
