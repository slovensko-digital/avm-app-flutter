import 'dart:async' show StreamSubscription, unawaited;
import 'dart:io' show Platform;

import 'package:autogram_sign/autogram_sign.dart'
    show IAutogramService, generateAsymmetricKeyPair, generateEncryptionKey;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'
    show WidgetsBinding, WidgetsBindingObserver, AppLifecycleState;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart' show Logger;

import '../app_service.dart';
import '../deep_links.dart';
import '../push_messages.dart';
import 'device_registry.dart';

enum PushNotificationStatus {
  notRegistered,
  ready,
  permissionDenied,
  registrationExpired,
  unavailable,
}

/// Handles push notifications with sign requests from paired integrations.
///
/// Notification taps open a document via [AppService.newIncomingUri].
/// Foreground messages are offered to the UI without interrupting active work.
@singleton
class PushNotificationService with WidgetsBindingObserver {
  static final _logger = Logger('PushNotificationService');

  final AppService _appService;
  final DeviceRegistry _deviceRegistry;
  final IAutogramService _service;
  final FirebaseMessaging _messaging;
  final _foregroundMessage = ValueNotifier<SignRequestMessage?>(null);
  final _status = ValueNotifier(PushNotificationStatus.notRegistered);
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  int _statusRevision = 0;
  bool _disposed = false;

  Future<RegisteredDevice>? _registration;

  ValueListenable<SignRequestMessage?> get foregroundMessage =>
      _foregroundMessage;
  ValueListenable<PushNotificationStatus> get status => _status;

  PushNotificationService(
    this._appService,
    this._deviceRegistry,
    this._service,
    this._messaging,
  );

  /// Starts listening for push notifications.
  Future<void> init() async {
    // App in foreground
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen((message) {
        unawaited(_handleMessage(message, foreground: true));
      }),
    );
    // App in background, user tapped notification
    _subscriptions.add(FirebaseMessaging.onMessageOpenedApp.listen(_onMessage));
    _subscriptions.add(
      _messaging.onTokenRefresh.listen(
        (token) => unawaited(refreshStatus(registrationId: token)),
        onError: (Object error, StackTrace stackTrace) {
          _logger.severe("Error refreshing FCM token.", error, stackTrace);
          _statusRevision++;
          _status.value = PushNotificationStatus.unavailable;
        },
      ),
    );
    WidgetsBinding.instance.addObserver(this);
    unawaited(refreshStatus());

    // App was terminated, user tapped notification
    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      _onMessage(initialMessage);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refreshStatus());
    }
  }

  /// Checks existing registration without replacing it or losing its pairings.
  Future<void> refreshStatus({String? registrationId}) async {
    final revision = ++_statusRevision;
    PushNotificationStatus value;

    try {
      final device = await _deviceRegistry.load();
      if (device == null) {
        value = PushNotificationStatus.notRegistered;
      } else if (device.registrationId !=
          (registrationId ?? await _getToken())) {
        _logger.warning(
          "FCM token changed; integrations need to be paired again.",
        );
        value = PushNotificationStatus.registrationExpired;
      } else {
        value =
            _notificationsAllowed(await _messaging.getNotificationSettings())
            ? PushNotificationStatus.ready
            : PushNotificationStatus.permissionDenied;
      }
    } catch (error, stackTrace) {
      _logger.severe(
        "Error checking push notification status.",
        error,
        stackTrace,
      );
      value = PushNotificationStatus.unavailable;
    }

    if (!_disposed && revision == _statusRevision) {
      _status.value = value;
    }
  }

  @disposeMethod
  Future<void> dispose() async {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _foregroundMessage.dispose();
    _status.dispose();
  }

  static bool _notificationsAllowed(NotificationSettings settings) {
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Pairs this device with integration using [pairingToken] from QR code
  /// "integration" param, so it can receive sign requests from it.
  ///
  /// Registers this device at server first, if needed.
  /// Returns whether system notifications are allowed after pairing.
  Future<bool> pairIntegration(String pairingToken) async {
    final settings = await _messaging.requestPermission();

    final notificationsAllowed = _notificationsAllowed(settings);
    if (!notificationsAllowed) {
      _logger.warning("Notifications permission denied.");
    }

    final device = await _ensureRegistered();

    _logger.info("Pairing integration with $device.");

    await _service.registerDeviceIntegration(pairingToken);

    _logger.info("Integration paired.");
    await refreshStatus();
    return notificationsAllowed;
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
      if (device == null) {
        return false;
      }
      await refreshStatus();
      if (_status.value == PushNotificationStatus.registrationExpired ||
          _status.value == PushNotificationStatus.unavailable) {
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
    await refreshStatus();

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

  Future<void> _handleMessage(
    RemoteMessage message, {
    bool foreground = false,
  }) async {
    final value = message.data[signRequestMessageKey];

    if (value is! String) {
      _logger.warning("Received unsupported message: ${message.messageId}.");
      return;
    }

    try {
      final device = await _deviceRegistry.load();
      final signRequest = parseSignRequestMessage(value, device?.pushkey);

      _logger.info("Received $signRequest.");

      if (_disposed) return;
      if (foreground) {
        _foregroundMessage.value = signRequest;
      } else {
        _appService.newIncomingUri(signRequest.toUri().toString());
      }
    } catch (error, stackTrace) {
      _logger.severe("Error parsing sign request.", error, stackTrace);
    }
  }
}
