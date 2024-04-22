import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// AVM close icon button.
class CloseButton extends StatelessWidget {
  const CloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      side: BorderSide(
        width: 2,
        color: Theme.of(context).dividerColor.withOpacity(0.10),
      ),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );

    return RawMaterialButton(
      constraints: const BoxConstraints(
        minWidth: kMinInteractiveDimension,
        minHeight: kMinInteractiveDimension,
      ),
      shape: shape,
      onPressed: () {
        Navigator.maybeOf(context)?.maybePop();
      },
      child: const Icon(Icons.close_outlined),
    );
  }
}

@widgetbook.UseCase(
  path: '[AVM]',
  name: 'CloseButton',
  type: CloseButton,
)
Widget previewCloseButton(BuildContext context) {
  return const CloseButton();
}
