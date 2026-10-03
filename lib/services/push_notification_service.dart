import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:autogram_sign/autogram_sign.dart'
    show IAutogramService, generateAsymmetricKeyPair, generateEncryptionKey;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart' show Logger;

import '../app_service.dart';
import '../deep_links.dart';
import '../push_messages.dart';
import 'device_registry.dart';

/// Handles push notifications with sign requests from paired integrations.
///
/// Received sign request is handled same way as opened URL or scanned QR code
/// - via [AppService.newIncomingUri].
@singleton
class PushNotificationService {
  static final _logger = Logger('PushNotificationService');

  final AppService _appService;
  final DeviceRegistry _deviceRegistry;
  final IAutogramService _service;

  Future<RegisteredDevice>? _registration;

  PushNotificationService(
    this._appService,
    this._deviceRegistry,
    this._service,
  );

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  /// Starts listening for push notifications.
  Future<void> init() async {
    // App in foreground
    FirebaseMessaging.onMessage.listen(_onMessage);
    // App in background, user tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessage);

    // App was terminated, user tapped notification
    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      _onMessage(initialMessage);
    }
  }

  /// Pairs this device with integration using [pairingToken] from QR code
  /// "integration" param, so it can receive sign requests from it.
  ///
  /// Registers this device at server first, if needed.
  Future<void> pairIntegration(String pairingToken) async {
    final settings = await _messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      _logger.warning("Notifications permission denied.");
    }

    final device = await _ensureRegistered();

    _logger.info("Pairing integration with $device.");

    await _service.registerDeviceIntegration(pairingToken);

    _logger.info("Integration paired.");
  }

  /// Returns `true` if this device is already paired with integration from
  /// [pairingToken], so there is no need to pair (and confirm) it again.
  ///
  /// Returns `false` when it can't be checked.
  Future<bool> isIntegrationPaired(String pairingToken) async {
    final integrationId = getPairingTokenIntegrationId(pairingToken);

    if (integrationId == null) {
      return false;
    }

    try {
      final device = await _deviceRegistry.load();

      // Not registered or registration ID changed - needs to be registered
      // again, which loses all previous pairings
      if (device == null || device.registrationId != await _getToken()) {
        return false;
      }

      final integrations = await _service.listIntegrations();

      return integrations.any((e) => e.integrationId == integrationId);
    } catch (error, stackTrace) {
      _logger.warning("Error checking paired integrations.", error, stackTrace);

      return false;
    }
  }

  Future<RegisteredDevice> _ensureRegistered() {
    // Avoid concurrent registrations
    return _registration ??= _register().whenComplete(() {
      _registration = null;
    });
  }

  Future<RegisteredDevice> _register() async {
    final registrationId = await _getToken();
    final existingDevice = await _deviceRegistry.load();

    if (existingDevice != null &&
        existingDevice.registrationId == registrationId) {
      return existingDevice;
    }

    // Server cannot update registration ID, so new device is registered
    // and previously paired integrations are lost
    _logger.info("Registering device; existing: $existingDevice.");

    final keyPair = generateAsymmetricKeyPair();
    final pushkey = generateEncryptionKey();
    final response = await _service.registerDevice(
      registrationId: registrationId,
      displayName: await _getDeviceDisplayName(),
      publicKey: keyPair.publicKey,
      pushkey: pushkey,
    );
    final device = RegisteredDevice(
      id: response.guid!,
      privateKey: keyPair.privateKey,
      pushkey: pushkey,
      registrationId: registrationId,
    );

    await _deviceRegistry.save(device);

    _logger.info("Device registered: $device.");

    return device;
  }

  Future<String> _getToken() async {
    if (Platform.isIOS) {
      // FCM token is not available until APNs token is set
      for (var i = 0; i < 10; i++) {
        if (await _messaging.getAPNSToken() != null) break;

        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    final token = await _messaging.getToken();

    if (token == null) {
      throw StateError("FCM token is not available.");
    }

    return token;
  }

  /// Returns name shown in paired integrations, e.g.
  /// "Autogram v mobile (iPhone 15 Pro)".
  static Future<String> _getDeviceDisplayName() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceName;

    try {
      if (Platform.isIOS) {
        // User-assigned name requires special entitlement, so use model name
        deviceName = (await deviceInfo.iosInfo).modelName;
      } else {
        final info = await deviceInfo.androidInfo;

        // User-assigned name, defaults to marketing name (e.g. "Galaxy S23")
        deviceName = info.name.trim().isNotEmpty ? info.name : info.model;
      }
    } catch (error, stackTrace) {
      _logger.warning("Cannot get device name.", error, stackTrace);
      deviceName = Platform.isIOS ? "iOS" : "Android";
    }

    return "Autogram v mobile ($deviceName)";
  }

  void _onMessage(RemoteMessage message) {
    unawaited(_handleMessage(message));
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    final value = message.data[signRequestMessageKey];

    if (value is! String) {
      _logger.warning("Received unsupported message: ${message.messageId}.");
      return;
    }

    try {
      final device = await _deviceRegistry.load();
      final signRequest = parseSignRequestMessage(value, device?.pushkey);

      _logger.info("Received $signRequest.");

      _appService.newIncomingUri(signRequest.toUri().toString());
    } catch (error, stackTrace) {
      _logger.severe("Error parsing sign request.", error, stackTrace);
    }
  }
}
