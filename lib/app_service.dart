import 'dart:io' show File, Directory, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:path_provider/path_provider.dart' as provider;

import 'file_extensions.dart';

/// Provides platform (iOS and Android) specific app functions:
///
/// Events:
///  - [incomingUri]
///
/// Methods:
///  - [startQrCodeScanner]
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

  /// Holds latest incoming URI - e.g.: shared file or open URL.
  static final _incomingUri = _CustomValueNotifier<Uri?>(null);

  /// Latest incoming URI.
  ///
  /// It can be either:
  ///  1. shared file:
  ///     - on **iOS**, it's "file://" URI that can be directly used
  ///     - on **Android**, it will be "content://" URI
  ///
  ///     therefore you need to call [getFileName] and [getFile]
  ///  2. open URL from deep link
  ValueListenable<Uri?> get incomingUri => _incomingUri;

  AppService._() {
    _events.receiveBroadcastStream("incomingUri").forEach(_collectIncomingUri);
  }

  /// Returns singleton [AppService].
  @factoryMethod
  factory AppService() {
    return _instance;
  }

  /// Starts platform camera / QR code scanner.
  Future<void> startQrCodeScanner() {
    if (Platform.isAndroid) {
      return _methods.invokeMethod<void>('startQrCodeScanner');
    }

    if (Platform.isIOS) {
      // TODO Impl. startQrCodeScanner on iOS
      throw UnimplementedError("Not implemented on iOS.");
    }

    throw UnsupportedError("Not supported on this platform.");
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

  static _collectIncomingUri(dynamic value) {
    if (value is String && value.isNotEmpty) {
      final uri = Uri.tryParse(value);

      if (uri != null) {
        // Expected schemes:
        // content:
        // file://
        // https:
        // avm:
        _logger.info("Received URI: $uri");
        _incomingUri.value = uri;
      }
    }
  }
}

class _CustomValueNotifier<T> extends ChangeNotifier
    implements ValueListenable<T> {
  _CustomValueNotifier(this._value) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  @override
  T get value => _value;
  T _value;

  set value(T newValue) {
    // DON'T compare and always notify listeners
    _value = newValue;
    notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
