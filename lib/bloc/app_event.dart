import 'package:flutter/foundation.dart';

import 'app_bloc.dart';

/// Event for the [AppBloc].
@immutable
sealed class AppEvent {
  const AppEvent();

  @override
  String toString() {
    return "$runtimeType()";
  }
}

/// "Request open file" event.
class RequestOpenFileEvent extends AppEvent {
  const RequestOpenFileEvent() : super();
}
