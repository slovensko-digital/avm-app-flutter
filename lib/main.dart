import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding, runApp;
import 'package:logging/logging.dart' show Level, LogRecord, Logger;
import 'package:provider/provider.dart' show MultiProvider, Provider;

import 'app.dart';
import 'data/settings.dart';
import 'di.dart';
import 'firebase_options.dart';
import 'utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup Logger
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(_onRecord);

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

/// [Logger] log callback.
void _onRecord(final LogRecord record) {
  if (kDebugMode) {
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
  } else {
    // TODO Collect also some Settings (on init and on change)
    FirebaseCrashlytics.instance.log(formatCrashlyticsLog(record));
  }
}
