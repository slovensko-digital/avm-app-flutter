import 'package:flutter/material.dart';

import '../../services/push_notification_service.dart';
import '../../strings_context.dart';
import '../app_theme.dart';

class PushNotificationStatusBanner extends StatelessWidget {
  final PushNotificationStatus status;
  final VoidCallback? onRetry;

  const PushNotificationStatusBanner({
    super.key,
    required this.status,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final message = switch (status) {
      PushNotificationStatus.permissionDenied =>
        strings.notificationsDeniedMessage,
      PushNotificationStatus.registrationExpired =>
        strings.pairingRenewalRequiredMessage,
      PushNotificationStatus.unavailable =>
        strings.notificationStatusUnavailableMessage,
      _ => null,
    };
    if (message == null) return const SizedBox.shrink();

    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: kScreenMargin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (status == PushNotificationStatus.unavailable && onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text(strings.buttonRetryLabel),
              ),
          ],
        ),
      ),
    );
  }
}
