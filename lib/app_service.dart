import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@injectable
@singleton
class AppService {
  // TODO Implement both functions also in iOS
  static const _platform = MethodChannel('digital.slovensko.autogram');

  const AppService();

  /// Returns only file name that was shared to this app.
  Future<String?> getSharedFileName() {
    if (Platform.isAndroid) {
      return _platform.invokeMethod<String?>('getSharedFileName');
    }

    // Return null so it won't crash on iOS
    return Future.value(null);
  }

  /// Returns absolute accessible path to file that was shared to this app.
  Future<File?> getSharedFile() {
    if (Platform.isAndroid) {
      return _platform
          .invokeMethod<String?>('getSharedFile')
          .then((value) => (value != null ? File(value) : null));
    }

    throw UnimplementedError(
        "Method 'getSharedFileName' is not implemented in iOS.");
  }

  /// Returns [Directory] with path to the public "Downloads" directory.
  Future<Directory> getDownloadsDirectory() {
    if (Platform.isAndroid) {
      return _platform
          .invokeMethod<String>('getDownloadsDirectory')
          .then((path) => Directory(path!));
    }

    throw UnimplementedError(
        "Method 'getDownloadsDirectory' is not implemented in iOS.");
  }
}
