import 'dart:async';

import 'package:autogram/app_service.dart';
import 'package:autogram/services/device_registry.dart';
import 'package:autogram/services/push_notification_service.dart';
import 'package:autogram_sign/autogram_sign.dart';
import 'package:basic_utils/basic_utils.dart' show ECPublicKey;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart'
    show FirebaseMessagingPlatform;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _AppService app;
  late _Registry registry;
  late _Messaging messaging;
  late _AutogramService api;
  late PushNotificationService service;
  final keyPair = generateAsymmetricKeyPair();
  final device = RegisteredDevice(
    id: 'device',
    privateKey: keyPair.privateKey,
    pushkey: generateEncryptionKey(),
    registrationId: 'old-token',
  );
  const message = RemoteMessage(
    data: {
      'encrypted_message':
          '{"document_guid":"document","documentEncryptionKey":"key"}',
    },
  );

  Future<void> flushEvents() => Future<void>.delayed(Duration.zero);

  setUp(() {
    app = _AppService();
    registry = _Registry()..device = device;
    messaging = _Messaging();
    api = _AutogramService();
    service = PushNotificationService(app, registry, api, messaging);
  });

  tearDown(() async {
    await service.dispose();
    await messaging.tokens.close();
  });

  test('startup detects expired registration without replacing it', () async {
    messaging.token = 'new-token';
    await service.init();
    await flushEvents();

    expect(service.status.value, PushNotificationStatus.registrationExpired);
    expect(registry.device, same(device));
    expect(registry.saves, 0);
    expect(api.registrations, 0);
  });

  test(
    'token refresh invalidates registration without losing credentials',
    () async {
      await service.init();
      await flushEvents();
      expect(service.status.value, PushNotificationStatus.ready);

      messaging.tokens.add('new-token');
      await flushEvents();
      expect(service.status.value, PushNotificationStatus.registrationExpired);
      expect(registry.device, same(device));
      expect(api.registrations, 0);
    },
  );

  test('unregistered startup does not request a token or permission', () async {
    registry.device = null;
    await service.init();
    await flushEvents();

    expect(service.status.value, PushNotificationStatus.notRegistered);
    expect(messaging.tokenRequests, 0);
    expect(messaging.permissionRequests, 0);
  });

  for (final authorization in [
    AuthorizationStatus.denied,
    AuthorizationStatus.notDetermined,
    AuthorizationStatus.authorized,
    AuthorizationStatus.provisional,
  ]) {
    test('pairing reports notification permission: $authorization', () async {
      messaging.authorization = authorization;
      final allowed =
          authorization == AuthorizationStatus.authorized ||
          authorization == AuthorizationStatus.provisional;

      expect(await service.pairIntegration('pairing-token'), allowed);
      expect(api.pairings, ['pairing-token']);
      expect(api.registrations, 0);
      expect(
        service.status.value,
        allowed
            ? PushNotificationStatus.ready
            : PushNotificationStatus.permissionDenied,
      );
    });
  }

  test(
    'resume rechecks notification permissions without requesting them',
    () async {
      await service.refreshStatus();
      messaging.authorization = AuthorizationStatus.denied;
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await flushEvents();

      expect(service.status.value, PushNotificationStatus.permissionDenied);
      expect(messaging.permissionRequests, 0);
      messaging.authorization = AuthorizationStatus.authorized;
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await flushEvents();
      expect(service.status.value, PushNotificationStatus.ready);
    },
  );

  test('token lookup errors are visible and can be retried', () async {
    messaging.tokenError = StateError('offline');
    await service.refreshStatus();
    expect(service.status.value, PushNotificationStatus.unavailable);
    expect(registry.device, same(device));

    messaging.tokenError = null;
    await service.refreshStatus();
    expect(service.status.value, PushNotificationStatus.ready);
  });

  test('token stream errors invalidate a previously ready status', () async {
    await service.init();
    await flushEvents();
    messaging.tokens.addError(
      StateError('token refresh failed'),
      StackTrace.current,
    );
    await flushEvents();
    expect(service.status.value, PushNotificationStatus.unavailable);
  });

  test(
    'explicit pairing replaces expired registration and clears warning',
    () async {
      messaging.token = 'new-token';
      await service.refreshStatus();
      expect(service.status.value, PushNotificationStatus.registrationExpired);

      expect(await service.pairIntegration('pairing-token'), isTrue);
      expect(api.registrations, 1);
      expect(registry.saves, 1);
      expect(registry.device?.registrationId, 'new-token');
      expect(api.pairings, ['pairing-token']);
      expect(service.status.value, PushNotificationStatus.ready);
    },
  );

  test(
    'pairing API failure remains an error, not a permission result',
    () async {
      api.pairingError = StateError('pairing failed');
      await expectLater(
        service.pairIntegration('pairing-token'),
        throwsStateError,
      );
    },
  );

  test(
    'foreground delivery does not invoke incoming document navigation',
    () async {
      await service.init();
      FirebaseMessagingPlatform.onMessage.add(message);
      await flushEvents();

      expect(app.incoming, isEmpty);
      expect(service.foregroundMessage.value?.documentGuid, 'document');
    },
  );

  test('tapping a background notification still opens its document', () async {
    await service.init();
    FirebaseMessagingPlatform.onMessageOpenedApp.add(message);
    await flushEvents();

    expect(app.incoming, hasLength(1));
    expect(Uri.parse(app.incoming.single).queryParameters['guid'], 'document');
    expect(service.foregroundMessage.value, isNull);
  });

  test('cold-start notification still opens its document', () async {
    messaging.initialMessage = message;
    await service.init();
    await flushEvents();
    expect(app.incoming, hasLength(1));
    expect(service.foregroundMessage.value, isNull);
  });

  test(
    'repeated foreground requests for the same document are delivered',
    () async {
      var deliveries = 0;
      service.foregroundMessage.addListener(() => deliveries++);
      await service.init();
      FirebaseMessagingPlatform.onMessage.add(message);
      await flushEvents();
      FirebaseMessagingPlatform.onMessage.add(message);
      await flushEvents();
      expect(deliveries, 2);
      expect(app.incoming, isEmpty);
    },
  );

  test(
    'an older check cannot overwrite a newer token refresh result',
    () async {
      final settings = Completer<NotificationSettings>();
      messaging.pendingSettings = settings.future;
      final olderCheck = service.refreshStatus();
      await flushEvents();

      await service.refreshStatus(registrationId: 'new-token');
      settings.complete(_Settings(AuthorizationStatus.authorized));
      await olderCheck;
      expect(service.status.value, PushNotificationStatus.registrationExpired);
    },
  );
}

class _AppService extends Fake implements AppService {
  final incoming = <String>[];

  @override
  void newIncomingUri(String uri) => incoming.add(uri);
}

class _Registry extends DeviceRegistry {
  RegisteredDevice? device;
  int saves = 0;

  @override
  Future<RegisteredDevice?> load() async => device;

  @override
  Future<void> save(RegisteredDevice device) async {
    saves++;
    this.device = device;
  }
}

class _Settings extends Fake implements NotificationSettings {
  @override
  final AuthorizationStatus authorizationStatus;

  _Settings(this.authorizationStatus);
}

class _Messaging extends Fake implements FirebaseMessaging {
  final tokens = StreamController<String>.broadcast();
  String token = 'old-token';
  AuthorizationStatus authorization = AuthorizationStatus.authorized;
  RemoteMessage? initialMessage;
  Object? tokenError;
  int tokenRequests = 0;
  int permissionRequests = 0;
  Future<NotificationSettings>? pendingSettings;

  @override
  Stream<String> get onTokenRefresh => tokens.stream;

  @override
  Future<RemoteMessage?> getInitialMessage() async => initialMessage;

  @override
  Future<String?> getToken({
    String? vapidKey,
    String? serviceWorkerScriptPath,
  }) async {
    tokenRequests++;
    final error = tokenError;
    if (error != null) throw error;
    return token;
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async =>
      await pendingSettings ?? _Settings(authorization);

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  }) async {
    permissionRequests++;
    return _Settings(authorization);
  }
}

class _AutogramService extends Fake implements IAutogramService {
  int registrations = 0;
  final pairings = <String>[];
  Object? pairingError;

  @override
  Future<PostDeviceResponse> registerDevice({
    required String registrationId,
    required String displayName,
    required ECPublicKey publicKey,
    required String pushkey,
  }) async {
    registrations++;
    return const PostDeviceResponse(guid: 'new-device');
  }

  @override
  Future<void> registerDeviceIntegration(String integrationPairingToken) async {
    final error = pairingError;
    if (error != null) throw error;
    pairings.add(integrationPairingToken);
  }
}
