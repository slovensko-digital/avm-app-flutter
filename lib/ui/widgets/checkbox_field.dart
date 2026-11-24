import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Checkbox with [label] - ID-SK 3 "Začiarkavacie pole".
///
/// Dimensions and colors are from `govuk-checkboxes` in `@id-sk/frontend`,
/// see https://idsk.gov.sk/komponenty/zaciarkavacie-pole
///
/// The whole field, including the [label], toggles the [value]. It is disabled
/// when [onChanged] is `null`.
class CheckboxField extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget label;

  const CheckboxField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  State<CheckboxField> createState() => _CheckboxFieldState();
}

class _CheckboxFieldState extends State<CheckboxField> {
  bool _focused = false;
  bool _hovered = false;

  bool get _enabled => widget.onChanged != null;

  void _toggle() {
    widget.onChanged?.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return MergeSemantics(
      child: Semantics(
        checked: widget.value,
        enabled: _enabled,
        child: FocusableActionDetector(
          enabled: _enabled,
          mouseCursor: _enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          onShowFocusHighlight: (value) => setState(() => _focused = value),
          onShowHoverHighlight: (value) => setState(() => _hovered = value),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) => _toggle(),
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _enabled ? _toggle : null,
            child: Opacity(
              opacity: _enabled ? 1 : 0.5,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomPaint(
                    size: const Size.square(_CheckboxPainter.touchTargetSize),
                    painter: _CheckboxPainter(
                      checked: widget.value,
                      focused: _focused,
                      hovered: _hovered && _enabled,
                      color: color,
                    ),
                  ),
                  Flexible(
                    // label is vertically centered with the box
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: _CheckboxPainter.touchTargetSize,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: 1,
                        heightFactor: 1,
                        child: Padding(
                          // govuk-spacing(1) + border width, govuk-spacing(3)
                          padding: const EdgeInsets.symmetric(
                            vertical: 7,
                            horizontal: 15,
                          ),
                          child: widget.label,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints `.govuk-checkboxes__label::before` box and `::after` check mark
/// within the touch target of `.govuk-checkboxes__input`.
class _CheckboxPainter extends CustomPainter {
  static const touchTargetSize = 40.0;
  static const _boxSize = 36.0;
  static const _borderWidth = 2.0;
  static const _borderRadius = 5.0;
  static const _focusColor = Color(0xFFD96E00);
  static const _focusWidth = 3.0;
  static const _focusOffset = 3.0;
  static const _hoverColor = Color(0xFFEEEEEE);
  static const _hoverWidth = 10.0;

  static const _box = Rect.fromLTWH(
    (touchTargetSize - _boxSize) / 2,
    (touchTargetSize - _boxSize) / 2,
    _boxSize,
    _boxSize,
  );

  /// Check mark - box with 5px left and bottom border (└), 23x12 at 10, 13,
  /// rotated by -45°.
  static final _checkMark = () {
    const width = 23.0, height = 12.0, border = 5.0;
    final shape = Path()
      ..addPolygon(const [
        Offset(0, 0),
        Offset(border, 0),
        Offset(border, height - border),
        Offset(width, height - border),
        Offset(width, height),
        Offset(0, height),
      ], true);
    final transform = Matrix4.identity()
      ..translateByDouble(10 + width / 2, 13 + height / 2, 0, 1)
      ..rotateZ(-pi / 4)
      ..translateByDouble(-width / 2, -height / 2, 0, 1);

    return shape.transform(transform.storage);
  }();

  final bool checked;
  final bool focused;
  final bool hovered;
  final Color color;

  const _CheckboxPainter({
    required this.checked,
    required this.focused,
    required this.hovered,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final box = RRect.fromRectAndRadius(
      _box,
      const Radius.circular(_borderRadius),
    );

    if (hovered) {
      canvas.drawDRRect(
        box.inflate(_hoverWidth),
        box,
        Paint()..color = _hoverColor,
      );
    }

    canvas.drawRRect(
      box.deflate(_borderWidth / 2),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _borderWidth,
    );

    if (checked) {
      canvas.drawPath(_checkMark, Paint()..color = color);
    }

    if (focused) {
      canvas.drawRRect(
        box.inflate(_focusOffset + _focusWidth / 2),
        Paint()
          ..color = _focusColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = _focusWidth,
      );
    }
  }

  @override
  bool shouldRepaint(_CheckboxPainter oldDelegate) {
    return checked != oldDelegate.checked ||
        focused != oldDelegate.focused ||
        hovered != oldDelegate.hovered ||
        color != oldDelegate.color;
  }
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'CheckboxField',
  type: CheckboxField,
)
Widget previewCheckboxField(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  final label = context.knobs.string(
    label: 'Label',
    initialValue: "Dôverovať tomuto zdroju aj nabudúce",
  );
  bool value = false;

  return StatefulBuilder(
    builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: CheckboxField(
          value: value,
          onChanged: enabled ? (v) => setState(() => value = v) : null,
          label: Text(label),
        ),
      );
    },
  );
}
