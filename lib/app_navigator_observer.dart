import 'package:flutter/material.dart';
import 'package:logging/logging.dart' show Logger;

/// [NavigatorObserver] that logs navigation events.
class AppNavigatorObserver extends NavigatorObserver {
  static final _logger = Logger((AppNavigatorObserver).toString());

  @override
  void didPush(Route route, Route? previousRoute) {
    _log("Did push", {'route': route, 'previousRoute': previousRoute});
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _log("Did pop", {'route': route, 'previousRoute': previousRoute});
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _log("Did remove", {'route': route, 'previousRoute': previousRoute});
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _log("Did replace", {'newRoute': newRoute, 'oldRoute': oldRoute});
  }

  /// Logs navigation event.
  static void _log(String event, Map<String, Route?> routes) {
    // Maps params into: "param1: value, param2: value"
    final params = routes.keys
        .map((param) => "$param: ${routes[param]?.debug}")
        .join(", ");

    _logger.info("$event - $params");
  }
}

extension _RouteExtensions<T> on Route<T> {
  /// Returns debug string for this [Route].
  String? get debug {
    final route = this;

    if (route is! MaterialPageRoute) {
      return route.settings.name;
    }

    final text = (route as MaterialPageRoute).builder.runtimeType.toString();

    // "(BuildContext) => NameScreen"
    return text.replaceFirst("(BuildContext) => ", "");
  }
}
