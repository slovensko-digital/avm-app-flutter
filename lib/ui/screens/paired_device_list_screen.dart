import 'dart:developer' as developer;

import 'package:autogram_sign/autogram_sign.dart'
    show GetDeviceIntegrationsResponseBody$Item;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/paired_device_list_cubit.dart';
import '../../di.dart';
import '../../services/push_notification_service.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';
import '../widgets/push_notification_status_banner.dart';

/// Displays list of paired devices (integrations) that can send sign requests
/// as push notifications.
///
/// Uses [PairedDeviceListCubit].
class PairedDeviceListScreen extends StatelessWidget {
  const PairedDeviceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pushService = getIt.get<PushNotificationService>();
    return BlocProvider<PairedDeviceListCubit>(
      create: (context) {
        pushService.refreshStatus();
        return getIt.get<PairedDeviceListCubit>()..load();
      },
      child: BlocBuilder<PairedDeviceListCubit, PairedDeviceListState>(
        builder: (context, state) {
          return ValueListenableBuilder(
            valueListenable: pushService.status,
            builder: (context, status, _) => _Body(
              state: state,
              notificationStatus: status,
              onRetryStatus: pushService.refreshStatus,
              onDeleteRequested: (item) {
                context.read<PairedDeviceListCubit>().delete(item);
              },
            ),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final PairedDeviceListState state;
  final ValueSetter<GetDeviceIntegrationsResponseBody$Item> onDeleteRequested;
  final PushNotificationStatus notificationStatus;
  final VoidCallback? onRetryStatus;

  const _Body({
    required this.state,
    required this.onDeleteRequested,
    this.notificationStatus = PushNotificationStatus.notRegistered,
    this.onRetryStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.pairedDevicesTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            PushNotificationStatusBanner(
              status: notificationStatus,
              onRetry: onRetryStatus,
            ),
            Expanded(child: _getChild(context)),
          ],
        ),
      ),
    );
  }

  Widget _getChild(BuildContext context) {
    final strings = context.strings;

    return switch (state) {
      PairedDeviceListInitialState _ => const LoadingContent(),
      PairedDeviceListLoadingState _ => const LoadingContent(),
      PairedDeviceListErrorState state => ErrorContent(
        title: strings.pairedDevicesErrorHeading,
        error: state.error,
      ),
      PairedDeviceListSuccessState state when state.items.isEmpty => Center(
        child: Padding(
          padding: kScreenMargin,
          child: Text(
            strings.pairedDevicesEmpty,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      PairedDeviceListSuccessState state => ListView(
        children: [
          Padding(
            padding: kScreenMargin,
            child: Text(strings.pairedDevicesInfo),
          ),
          for (final item in state.items)
            ListTile(
              title: Text(item.displayName),
              subtitle: Text(item.platform),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: strings.pairedDeviceDeleteTooltip,
                onPressed: () => onDeleteRequested(item),
              ),
            ),
        ],
      ),
    };
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: '',
  type: PairedDeviceListScreen,
)
Widget previewPairedDeviceListScreen(BuildContext context) {
  return _Body(
    state: PairedDeviceListSuccessState([
      GetDeviceIntegrationsResponseBody$Item(
        integrationId: "1",
        platform: "extension",
        displayName: "Autogram Extension",
      ),
    ]),
    onDeleteRequested: (item) {
      developer.log('onDeleteRequested: $item');
    },
  );
}
