import 'dart:io';

import 'package:autogram/utils.dart';
import 'package:logging/logging.dart' show Level, LogRecord;
import 'package:test/test.dart';

/// Tests for the [formatCrashlyticsLog] function.
void main() {
  group('formatCrashlyticsLog', () {
    test('formatCrashlyticsLog formats simple log properly', () {
      final infoLog = LogRecord(Level.INFO, 'Hello world!', 'Logger1');
      final configLog = LogRecord(
        Level.CONFIG,
        'This has been configured.',
        'ConfigLogger',
      );

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
      final errorLog = LogRecord(
        Level.SEVERE,
        'Unable to download file.',
        'FileDownloader',
        error,
      );

      expect(
        formatCrashlyticsLog(errorLog),
        '${errorLog.time}: E/FileDownloader: Unable to download file.\n$error',
      );
    });

    test('formatCrashlyticsLog strips key, pushkey and guid properly', () {
      final log = LogRecord(
        Level.INFO,
        'QR code scanner result: https://autogram.slovensko.digital/api/v1/qr-code?guid=e7e95411-66a1-d401-e063-0a64dbb6b796&key=EeESAfZQh9OTf5qZhHZtgaDJpYtxZD6TIOQJzRgRFgQ%3D',
        'test',
      );

      expect(
        formatCrashlyticsLog(log),
        '${log.time}: I/test: QR code scanner result: https://autogram.slovensko.digital/api/v1/qr-code?guid=<REDACTED>&key=<REDACTED>',
      );
    });
  });
}
