import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import 'app.dart';
import 'di.dart';

void main() {
  // Setup DI
  configureDependencies();

  // Setup Logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen(_onRecord);

  // Run App
  runApp(const App());
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
