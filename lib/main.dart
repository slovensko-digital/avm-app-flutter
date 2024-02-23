import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'app.dart';
import 'di.dart';

void main() {
  configureDependencies();
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  runApp(const App());
}
