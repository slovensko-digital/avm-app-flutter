import 'package:flutter/foundation.dart';

/// Produces single [ValueListenable] from source [listenable1] & [listenable2]
/// using [transformation] function.
class TransformValueListenable<T1, T2, R> {
  late final ValueNotifier<R> _notifier;

  final ValueListenable<T1> listenable1;
  final ValueListenable<T2> listenable2;
  final R Function(T1 value1, T2 value2) transformation;

  /// Resulting [ValueListenable] from source [listenable1] & [listenable2]
  /// after [transformation] function was applied.
  ValueListenable<R> get listenable => _notifier;

  TransformValueListenable({
    required this.listenable1,
    required this.listenable2,
    required this.transformation,
  }) {
    _notifier = ValueNotifier(_getValue());

    listenable1.addListener(_commonListener);
    listenable2.addListener(_commonListener);
  }

  void _commonListener() {
    _notifier.value = _getValue();
  }

  R _getValue() {
    final value1 = listenable1.value;
    final value2 = listenable2.value;

    return transformation(value1, value2);
  }

  void dispose() {
    listenable1.removeListener(_commonListener);
    listenable2.removeListener(_commonListener);
  }
}
