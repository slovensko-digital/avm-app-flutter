import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding, runApp;
import 'package:logging/logging.dart' show Level, LogRecord, Logger;
import 'package:provider/provider.dart' show MultiProvider, Provider;

import 'app.dart';
import 'data/settings.dart';
import 'di.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup Logger
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(_onRecord);

  // Setup Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup DI
  configureDependencies();

  // Init Settings
  final settings = await Settings.create();

  // Run App
  runApp(
    MultiProvider(
      providers: [
        Provider<Settings>.value(value: settings),
      ],
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
