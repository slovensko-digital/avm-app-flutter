import 'package:autogram/foundation/transform_value_listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

/// Tests for the [TransformValueListenable] class.
void main() {
  group('TransformValueListenable', () {
    test('TransformValueListenable has initial value from two values', () {
      final vl1 = ValueNotifier<int>(1);
      final vl2 = ValueNotifier<int>(2);
      final tv = TransformValueListenable(
        listenable1: vl1,
        listenable2: vl2,
        transformation: (value1, value2) => value1 + value2,
      );

      expect(tv.listenable.value, 1 + 2);
    });

    test('TransformValueListenable notifies regarding new value', () {
      final vl1 = ValueNotifier<int>(1);
      final vl2 = ValueNotifier<int>(2);
      final tv = TransformValueListenable(
        listenable1: vl1,
        listenable2: vl2,
        transformation: (value1, value2) => value1 + value2,
      );
      List<int> changes = [];
      tv.listenable.addListener(() {
        changes.add(tv.listenable.value);
      });

      expect(tv.listenable.value, 3);
      expect(changes, isEmpty);

      vl1.value = 10;

      expect(tv.listenable.value, 10 + 2);
      expect(changes, [10 + 2]);

      vl2.value = 5;

      expect(tv.listenable.value, 10 + 5);
      expect(changes, [10 + 2, 10 + 5]);
    });
  });
}
