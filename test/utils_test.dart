import 'dart:io';

import 'package:autogram/utils.dart';
import 'package:logging/logging.dart' show Level, LogRecord;
import 'package:test/test.dart';

/// Tests for the [formatCrashlyticsLog] function.
void main() {
  group('formatCrashlyticsLog', () {
    test('formatCrashlyticsLog formats simple log properly', () {
      final infoLog = LogRecord(Level.INFO, 'Hello world!', 'Logger1');
      final configLog =
          LogRecord(Level.CONFIG, 'This has been configured.', 'ConfigLogger');

      expect(
        formatCrashlyticsLog(infoLog),
        '${infoLog.time}: I/Logger1: Hello world!',
      );
      expect(
        formatCrashlyticsLog(configLog),
        '${configLog.time}: D/ConfigLogger: This has been configured.',
      );
    });

    test('formatCrashlyticsLog formats log with error properly', () {
      const error = SocketException('No Internets!');
      final errorLog =
          LogRecord(Level.SEVERE, 'Unable to download file.', 'FileDownloader',  error);

      expect(
        formatCrashlyticsLog(errorLog),
        '${errorLog.time}: E/FileDownloader: Unable to download file.\n$error',
      );
    });
  });
}
