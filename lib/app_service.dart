import 'dart:io';

import 'package:flutter/foundation.dart' show ValueListenable, ValueNotifier;
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:path_provider/path_provider.dart' as provider;

import 'file_extensions.dart';

/// Provides platform (iOS and Android) specific app functions:
///  - [sharedFile]
///  - [getFileName]
///  - [getFile]
///  - [getDocumentsDirectory]
@singleton
class AppService {
  static final AppService _instance = AppService._();
  static final _logger = Logger('AppService');

  /// [MethodChannel] for all methods.
  static const _methods = MethodChannel('digital.slovensko.avm');

  /// [EventChannel] for all events.
  static const _events = EventChannel('digital.slovensko.avm/events');

  /// Holds URI to last shared file to app.
  static final _sharedFile = ValueNotifier<Uri?>(null);

  /// Last shared file to app.
  ///
  /// Note that:
  ///  - on **iOS**, it's file:// URI that can be directly used
  ///  - on **Android**, it will be content:// URI, therefore you need to call
  ///    [getFileName] and [getFile]
  ValueListenable<Uri?> get sharedFile => _sharedFile;

  AppService._() {
    _events.receiveBroadcastStream("sharedFile").forEach(_collectSharedFile);
  }

  /// Returns singleton [AppService].
  @factoryMethod
  factory AppService() {
    return _instance;
  }

  /// Gets the file name from [Uri].
  Future<String> getFileName(Uri uri) async {
    if (Platform.isAndroid) {
      // In Android need to read the file name from content:// scheme
      return _methods
          .invokeMethod<String?>('getFileName', uri.toString())
          .then((value) => value!);
    }

    // On iOS it's already file://
    return File.fromUri(uri).basename;
  }

  /// Gets the [File] from [Uri] that you can read.
  Future<File> getFile(Uri uri) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // In Android need to read the file from content:// scheme by saving it
      // In iOS, the file:// might be accessible only by using SecurityScopedResource
      return _methods
          .invokeMethod<String?>('getFile', uri.toString())
          .then((value) => File(value!));
    }

    return File.fromUri(uri);
  }

  /// Returns [Directory] with path where to store Documents.
  Future<Directory> getDocumentsDirectory() {
    if (Platform.isAndroid) {
      return _methods
          .invokeMethod<String>('getDownloadsDirectory')
          .then((path) => Directory(path!));
    }

    if (Platform.isIOS) {
      return provider.getApplicationDocumentsDirectory();
    }

    // On Android, this returns app specific path
    return provider.getDownloadsDirectory().then((value) => value!);
  }

  static _collectSharedFile(dynamic value) {
    if (value is String && value.isNotEmpty) {
      // Expecting content:// or file:// scheme
      final uri = Uri.tryParse(value);

      if (uri != null) {
        _logger.info("Received shared file: $uri");

        // TODO Fix case when shared the same file URI 2nd time
        // it might be an issue on iOS side
        _sharedFile.value = uri;
      }
    }
  }
}
