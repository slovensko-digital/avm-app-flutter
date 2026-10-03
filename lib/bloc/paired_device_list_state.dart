import 'package:autogram_sign/autogram_sign.dart'
    show GetDeviceIntegrationsResponseBody$Item;
import 'package:flutter/foundation.dart' show immutable;

import 'paired_device_list_cubit.dart';

/// State for [PairedDeviceListCubit].
@immutable
sealed class PairedDeviceListState {
  const PairedDeviceListState();

  PairedDeviceListLoadingState toLoading() {
    return const PairedDeviceListLoadingState();
  }

  PairedDeviceListSuccessState toSuccess(
    List<GetDeviceIntegrationsResponseBody$Item> items,
  ) {
    return PairedDeviceListSuccessState(items);
  }

  PairedDeviceListErrorState toError(Object error) {
    return PairedDeviceListErrorState(error);
  }

  @override
  String toString() {
    return "$runtimeType()";
  }
}

class PairedDeviceListInitialState extends PairedDeviceListState {
  const PairedDeviceListInitialState();
}

class PairedDeviceListLoadingState extends PairedDeviceListState {
  const PairedDeviceListLoadingState();
}

class PairedDeviceListErrorState extends PairedDeviceListState {
  final Object error;

  const PairedDeviceListErrorState(this.error);

  @override
  String toString() {
    return "$runtimeType(error: $error)";
  }
}

class PairedDeviceListSuccessState extends PairedDeviceListState {
  final List<GetDeviceIntegrationsResponseBody$Item> items;

  const PairedDeviceListSuccessState(this.items);

  @override
  String toString() {
    return "$runtimeType(items: ${items.length})";
  }
}
