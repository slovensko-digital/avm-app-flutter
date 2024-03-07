import 'dart:developer' as developer;

import 'package:flutter/widgets.dart' show WidgetsFlutterBinding, runApp;
import 'package:logging/logging.dart' show Level, LogRecord, Logger;
import 'package:provider/provider.dart' show Provider;

import 'app.dart';
import 'data/settings.dart';
import 'di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup DI
  configureDependencies();

  // Setup Logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen(_onRecord);

  // Init Settings
  final settings = Settings();
  await settings.initialize();

  // Run App
  runApp(
    Provider.value(
      value: settings,
      child: const App(),
    ),
  );
}

void _onRecord(final LogRecord record) {
  developer.log(
    record.message,
    name: record.loggerName,
    time: record.time,
    sequenceNumber: record.sequenceNumber,
    level: record.level.value,
    zone: record.zone,
    error: record.error,
    stackTrace: record.stackTrace,
  );
}
