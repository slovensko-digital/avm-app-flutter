import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart' as provider;

@injectable
@singleton
class AppService {
  static const _platform = MethodChannel('digital.slovensko.avm');

  const AppService();

  /// Returns only file name that was shared to this app.
  Future<String?> getSharedFileName() {
    if (Platform.isAndroid) {
      return _platform.invokeMethod<String?>('getSharedFileName');
    }

    // TODO Implement getSharedFileName also in iOS
    // Returns null so it won't crash on iOS
    return Future.value(null);
  }

  /// Returns absolute accessible path to file that was shared to this app.
  Future<File?> getSharedFile() {
    if (Platform.isAndroid) {
      return _platform
          .invokeMethod<String?>('getSharedFile')
          .then((value) => (value != null ? File(value) : null));
    }

    // TODO Implement getSharedFile also in iOS
    throw UnimplementedError(
        "Method 'getSharedFileName' is not implemented in iOS.");
  }

  /// Returns [Directory] with path where to store Documents.
  Future<Directory> getDocumentsDirectory() {
    if (Platform.isAndroid) {
      return _platform
          .invokeMethod<String>('getDownloadsDirectory')
          .then((path) => Directory(path!));
    }

    if (Platform.isIOS) {
      return provider.getApplicationDocumentsDirectory();
    }

    // On Android, this returns app specific path
    return provider.getDownloadsDirectory().then((value) => value!);
  }
}
