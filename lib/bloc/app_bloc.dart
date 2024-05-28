import 'package:flutter_bloc/flutter_bloc.dart' show Bloc;

import '../app.dart';
import 'app_event.dart';

export 'app_event.dart';

/// Bloc for the [App], where event type is used also as state, so it is
/// used as simple event bus.
class AppBloc extends Bloc<AppEvent, AppEvent?> {
  AppBloc() : super(null) {
    on<AppEvent>((event, emit) {
      emit(event);
    });
  }
}
