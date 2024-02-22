import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:localstorage/localstorage.dart';

LocalStorage useLocalStorage(
  String key, [
  String? path,
  Map<String, dynamic>? initialData,
  List<Object?> keys = const <Object>[],
]) {
  final localStorage =
      useMemoized(() => LocalStorage(key, path, initialData), keys);
  useFuture(localStorage.ready);
  return localStorage;
}

ValueNotifier<T?> useLocalStorageItem<T>(LocalStorage localStorage, String key,
    [T? Function()? defaultValue]) {
  final ready = useFuture(localStorage.ready);

  final value = useState<T?>(defaultValue != null ? defaultValue() : null);
  useEffect(() {
    value.value = localStorage.getItem(key);
    return null;
  }, [ready.data, localStorage, key]);

  useValueChanged<T?, T?>(value.value, (oldValue, oldResult) {
    localStorage.setItem(key, value.value);
    return value.value;
  });

  return value;
}
