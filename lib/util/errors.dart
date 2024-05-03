import 'dart:io' show IOException;

import 'package:autogram_sign/autogram_sign.dart' show ServiceException;
import 'package:flutter/services.dart' show PlatformException;

/// Extracts human-readable error message from [error].
String getErrorMessage(Object error) {
  return switch (error) {
    String _ => error,
    ServiceException error => error.message,
    // TODO Handle ServiceException(statusCode: 404, message: "")
    // TODO Extract error message from Object from other types; add tests
    // IOException - file not found, cannot be saved
    // SocketException - timeout
    // ArgumentError - file type not supported
    IOException error => (error as dynamic).message,
    PlatformException error => error.message ?? error.toString(),
    Exception error => (error as dynamic)?.message ?? error.toString(),
    _ => error.toString(),
  };
}
