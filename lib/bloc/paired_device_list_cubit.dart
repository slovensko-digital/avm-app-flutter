import 'dart:async';

import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart' show injectable;
import 'package:logging/logging.dart' show Logger;

import '../ui/screens/paired_device_list_screen.dart';
import 'paired_device_list_state.dart';

export 'paired_device_list_state.dart';

/// Cubit for the [PairedDeviceListScreen] with only [load] function.
@injectable
class PairedDeviceListCubit extends Cubit<PairedDeviceListState> {
  static final _log = Logger("PairedDeviceListScreen");

  // ignore: unused_field
  final IAutogramService _service;

  PairedDeviceListCubit({
    required IAutogramService service,
  })  : _service = service,
        super(const PairedDeviceListInitialState());

  Future<void> load() async {
    emit(state.toLoading());

    try {
      emit(state.toSuccess([]));
    } catch (error, stackTrace) {
      _log.severe("Error getting Paired device list.", error, stackTrace);

      emit(state.toError(error));
    }
  }
}
