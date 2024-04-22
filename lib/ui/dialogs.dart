import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../strings_context.dart';
import 'app_theme.dart';
import 'widgets/close_button.dart' as avm;
import 'widgets/result_view.dart';

/// Shows bottom sheet with rationale text for notifications permission.
Future<bool?> showNotificationsPermissionRationaleModal(BuildContext context) {
  final strings = context.strings;
  final child = Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ResultView(
          icon: const Image(
            image: AssetImage('assets/images/notification.png'),
            width: 96,
            height: 96,
          ),
          titleText: strings.notificationPermissionRationaleTitle,
          body: Text(strings.notificationPermissionRationaleMessage),
        ),
      ),
      const SizedBox(height: 60),
      FilledButton(
        style: TextButton.styleFrom(
          minimumSize: kPrimaryButtonMinimumSize,
        ),
        onPressed: () {
          Navigator.maybePop(context, true);
        },
        child: Text(strings.buttonAcknowledgeAndAgreeLabel),
      ),
      const SizedBox(height: kButtonSpace),
      TextButton(
        style: TextButton.styleFrom(
          minimumSize: kPrimaryButtonMinimumSize,
        ),
        onPressed: () {
          Navigator.maybePop(context, false);
        },
        child: Text(strings.buttonDisagreeLabel),
      ),
    ],
  );

  return _showModalBottomSheet<bool>(
    context: context,
    child: child,
  );
}

/// Calls Material [showModalBottomSheet] with predefined [child] wrapper
/// and [avm.CloseButton].
Future<T?> _showModalBottomSheet<T>({
  required BuildContext context,
  required Widget child,
}) {
  final widget = Padding(
    padding: kScreenMargin,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const avm.CloseButton(),
        child,
      ],
    ),
  );

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    constraints: const BoxConstraints(minWidth: double.infinity),
    builder: (context) => widget,
  );
}

@widgetbook.UseCase(
  path: '[Dialogs]',
  name: 'NotificationsPermissionRationale',
  type: BottomSheet,
)
Widget previewNotificationsPermissionRationaleModal(BuildContext context) {
  bool? result;

  return StatefulBuilder(
    builder: (context, setState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () async {
                final value =
                    await showNotificationsPermissionRationaleModal(context);

                setState(() => result = value);
              },
              child: const Text("Show modal"),
            ),
            Text("$result"),
          ],
        ),
      );
    },
  );
}
