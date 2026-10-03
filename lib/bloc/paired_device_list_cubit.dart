import 'dart:async';

import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart' show injectable;
import 'package:logging/logging.dart' show Logger;

import '../services/device_registry.dart';
import '../ui/screens/paired_device_list_screen.dart';
import 'paired_device_list_state.dart';

export 'paired_device_list_state.dart';

/// Cubit for the [PairedDeviceListScreen] with [load] and [delete] functions.
@injectable
class PairedDeviceListCubit extends Cubit<PairedDeviceListState> {
  static final _log = Logger((PairedDeviceListScreen).toString());

  final IAutogramService _service;
  final DeviceRegistry _deviceRegistry;

  PairedDeviceListCubit({
    required IAutogramService service,
    required DeviceRegistry deviceRegistry,
  })  : _service = service,
        _deviceRegistry = deviceRegistry,
        super(const PairedDeviceListInitialState());

  Future<void> load() async {
    emit(state.toLoading());

    try {
      // Not registered yet - nothing could be paired
      final device = await _deviceRegistry.load();
      final items = device != null
          ? await _service.listIntegrations()
          : <GetDeviceIntegrationsResponseBody$Item>[];

      emit(state.toSuccess(items));
    } catch (error, stackTrace) {
      _log.severe("Error getting Paired device list.", error, stackTrace);

      emit(state.toError(error));
    }
  }

  Future<void> delete(GetDeviceIntegrationsResponseBody$Item item) async {
    emit(state.toLoading());

    try {
      await _service.deleteIntegration(item.integrationId);
    } catch (error, stackTrace) {
      _log.severe("Error deleting Paired device.", error, stackTrace);

      emit(state.toError(error));

      return;
    }

    await load();
  }
}
