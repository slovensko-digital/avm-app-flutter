import 'package:autogram_sign/autogram_sign.dart'
    show createDeviceToken, PrivateKeyExtensions;
import 'package:basic_utils/basic_utils.dart' show CryptoUtils, ECPrivateKey;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Holds this device registration at Autogram server - used to receive
/// sign requests (push notifications) from paired integrations.
///
/// Values are kept in [FlutterSecureStorage].
@singleton
class DeviceRegistry {
  static const _storage = FlutterSecureStorage();
  static const _idKey = "device_id";
  static const _privateKeyKey = "device_private_key";
  static const _pushkeyKey = "device_pushkey";
  static const _registrationIdKey = "device_registration_id";

  RegisteredDevice? _device;
  bool _loaded = false;

  /// Returns registered device or `null` if not registered yet.
  Future<RegisteredDevice?> load() async {
    if (!_loaded) {
      final values = await _storage.readAll();
      final id = values[_idKey];
      final privateKey = values[_privateKeyKey];
      final pushkey = values[_pushkeyKey];
      final registrationId = values[_registrationIdKey];

      if (id != null &&
          privateKey != null &&
          pushkey != null &&
          registrationId != null) {
        _device = RegisteredDevice(
          id: id,
          privateKey: CryptoUtils.ecPrivateKeyFromPem(privateKey),
          pushkey: pushkey,
          registrationId: registrationId,
        );
      }

      _loaded = true;
    }

    return _device;
  }

  /// Saves newly registered [device].
  Future<void> save(RegisteredDevice device) async {
    await _storage.write(key: _idKey, value: device.id);
    await _storage.write(
      key: _privateKeyKey,
      value: device.privateKey.getEncoded(),
    );
    await _storage.write(key: _pushkeyKey, value: device.pushkey);
    await _storage.write(
      key: _registrationIdKey,
      value: device.registrationId,
    );

    _device = device;
    _loaded = true;
  }

  /// Creates new "Device JWT" or returns `null` if not registered.
  Future<String?> createToken() async {
    final device = await load();

    if (device == null) {
      return null;
    }

    return createDeviceToken(
      deviceId: device.id,
      privateKey: device.privateKey,
    );
  }
}

/// Device registered at Autogram server.
class RegisteredDevice {
  /// Device ID ("guid") assigned by server.
  final String id;

  /// Private key used to sign "Device JWT".
  final ECPrivateKey privateKey;

  /// Base64 encoded AES256 key to decrypt push notifications.
  final String pushkey;

  /// FCM registration token sent to server.
  final String registrationId;

  const RegisteredDevice({
    required this.id,
    required this.privateKey,
    required this.pushkey,
    required this.registrationId,
  });

  @override
  String toString() {
    return "$runtimeType(id: $id)";
  }
}
