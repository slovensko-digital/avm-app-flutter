import 'package:autogram/ui/widgets/checkbox_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [CheckboxField] - ID-SK 3 "Začiarkavacie pole", see
/// https://idsk.gov.sk/komponenty/zaciarkavacie-pole
void main() {
  const label = "Zapamätať si server";

  Widget host({
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CheckboxField(
          value: value,
          onChanged: onChanged,
          label: const Text(label),
        ),
      ),
    );
  }

  testWidgets('checks when the label is tapped', (tester) async {
    bool? changed;
    await tester.pumpWidget(host(value: false, onChanged: (v) => changed = v));

    await tester.tap(find.text(label));

    expect(changed, isTrue);
  });

  testWidgets('unchecks when the box is tapped', (tester) async {
    bool? changed;
    await tester.pumpWidget(host(value: true, onChanged: (v) => changed = v));

    await tester.tapAt(
      tester.getTopLeft(find.byType(CheckboxField)) + const Offset(20, 20),
    );

    expect(changed, isFalse);
  });

  testWidgets('toggles by space key when focused', (tester) async {
    bool? changed;
    await tester.pumpWidget(host(value: false, onChanged: (v) => changed = v));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);

    expect(changed, isTrue);
  });

  testWidgets('is announced as checkbox with the label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(value: true, onChanged: (_) {}));

    expect(
      tester.getSemantics(find.byType(CheckboxField)),
      isSemantics(
        label: label,
        hasCheckedState: true,
        isChecked: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );

    semantics.dispose();
  });

  testWidgets('draws ID-SK box with check mark', (tester) async {
    await tester.pumpWidget(host(value: true, onChanged: (_) {}));

    expect(
      find.byType(CheckboxField),
      paints
        // 36x36 box with 2px border and 5px radius, in 40x40 touch target
        ..rrect(
          rrect: RRect.fromLTRBR(3, 3, 37, 37, const Radius.circular(4)),
          style: PaintingStyle.stroke,
          strokeWidth: 2,
        )
        // └ with 5px thick sides, 23x12, rotated by -45° = ✔
        ..path(
          includes: const [Offset(13, 23.2), Offset(30, 15.5)],
          excludes: const [Offset(21.9, 14.4), Offset(20, 20)],
        ),
    );
  });

  testWidgets('draws no check mark when unchecked', (tester) async {
    await tester.pumpWidget(host(value: false, onChanged: (_) {}));

    expect(find.byType(CheckboxField), isNot(paints..path()));
  });

  testWidgets('draws orange outline when focused by keyboard', (
    tester,
  ) async {
    await tester.pumpWidget(host(value: false, onChanged: (_) {}));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    expect(
      find.byType(CheckboxField),
      paints
        ..rrect() // box
        // 3px outline with 3px offset around the box
        ..rrect(
          rrect: RRect.fromLTRBR(
            -2.5,
            -2.5,
            42.5,
            42.5,
            const Radius.circular(9.5),
          ),
          color: const Color(0xFFD96E00),
          style: PaintingStyle.stroke,
          strokeWidth: 3,
        ),
    );
  });

  testWidgets('disabled is dimmed', (tester) async {
    await tester.pumpWidget(host(value: false));

    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(CheckboxField),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, 0.5);
  });
}
