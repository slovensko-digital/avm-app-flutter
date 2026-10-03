import 'package:autogram/bloc/app_bloc.dart';
import 'package:autogram/bloc/document_validation_cubit.dart';
import 'package:autogram/bloc/paired_device_list_cubit.dart';
import 'package:autogram/bloc/preview_document_cubit.dart';
import 'package:autogram/data/settings.dart';
import 'package:autogram/di.dart';
import 'package:autogram/l10n/app_localizations.dart';
import 'package:autogram/l10n/app_localizations_sk.dart';
import 'package:autogram/push_messages.dart';
import 'package:autogram/services/device_registry.dart';
import 'package:autogram/services/encryption_key_registry.dart';
import 'package:autogram/services/push_notification_service.dart';
import 'package:autogram/ui/screens/main_screen.dart';
import 'package:autogram/ui/screens/paired_device_list_screen.dart';
import 'package:autogram/ui/screens/preview_document_screen.dart';
import 'package:autogram/ui/widgets/push_notification_status_banner.dart';
import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final strings = AppLocalizationsSk();
  const newDocument = SignRequestMessage(
    documentGuid: 'new-document',
    documentEncryptionKey: 'new-key',
  );
  late Settings settings;
  late AppBloc bloc;
  late EncryptionKeyRegistry keys;
  late ValueNotifier<SignRequestMessage?> foreground;
  late ValueNotifier<Uri?> incoming;
  late GlobalKey<NavigatorState> navigator;
  late _PushService pushService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = await Settings.create(await SharedPreferences.getInstance());
    bloc = AppBloc();
    keys = EncryptionKeyRegistry()..value = 'original-key';
    foreground = ValueNotifier(null);
    incoming = ValueNotifier(null);
    navigator = GlobalKey<NavigatorState>();
    pushService = _PushService();
    getIt.registerSingleton<EncryptionKeyRegistry>(keys);
    getIt.registerSingleton<PushNotificationService>(pushService);
    getIt.registerFactoryParam<PreviewDocumentCubit, String, dynamic>(
      (id, _) => _PreviewCubit(id),
    );
    getIt.registerFactory<DocumentValidationCubit>(() => _ValidationCubit());
  });

  tearDown(() async {
    await getIt.reset();
    await bloc.close();
    keys.dispose();
    foreground.dispose();
    incoming.dispose();
    pushService.status.dispose();
  });

  Widget host() => MultiProvider(
    providers: [
      Provider<Settings>.value(value: settings),
      Provider<AppBloc>.value(value: bloc),
    ],
    child: MaterialApp(
      navigatorKey: navigator,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ListenableBuilder(
        listenable: Listenable.merge([
          foreground,
          incoming,
          pushService.status,
        ]),
        builder: (_, _) => MainScreen(
          incomingUri: incoming.value,
          foregroundPush: foreground.value,
          pushNotificationStatus: pushService.status.value,
        ),
      ),
    ),
  );

  Future<void> openExistingDocument(WidgetTester tester) async {
    await tester.pumpWidget(host());
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Original document')),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'foreground push preserves active route and encryption key until tapped',
    (tester) async {
      await openExistingDocument(tester);
      foreground.value = newDocument;
      await tester.pumpAndSettle();

      expect(find.text('Original document'), findsOneWidget);
      expect(find.byType(PreviewDocumentScreen), findsNothing);
      expect(keys.value, 'original-key');
      expect(find.text(strings.newSignRequestMessage), findsOneWidget);

      await tester.tap(find.text(strings.openSignRequestLabel));
      await tester.pumpAndSettle();
      expect(find.text('Original document'), findsNothing);
      expect(find.byType(PreviewDocumentScreen), findsOneWidget);
      expect(keys.value, 'new-key');
      expect(
        tester
            .widget<PreviewDocumentScreen>(find.byType(PreviewDocumentScreen))
            .documentId,
        'new-document',
      );
    },
  );

  testWidgets('foreground push on main screen still opens directly', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    foreground.value = newDocument;
    await tester.pumpAndSettle();
    expect(find.byType(PreviewDocumentScreen), findsOneWidget);
    expect(keys.value, 'new-key');
  });

  testWidgets('explicit incoming notification replaces the active document', (
    tester,
  ) async {
    await openExistingDocument(tester);
    incoming.value = newDocument.toUri();
    await tester.pumpAndSettle();
    expect(find.text('Original document'), findsNothing);
    expect(find.byType(PreviewDocumentScreen), findsOneWidget);
    expect(keys.value, 'new-key');
  });

  testWidgets('denied permission is not reported as notification success', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    incoming.value = Uri.https(
      'autogram.slovensko.digital',
      '/api/v1/qr-code-register',
      {'integration': 'pairing-token'},
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(strings.notificationPermissionRationaleAcceptLabel),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(strings.pairIntegrationNotificationsDeniedMessage),
      findsOneWidget,
    );
    expect(find.text(strings.pairIntegrationSuccessMessage), findsNothing);
    expect(pushService.pairings, 1);
  });

  testWidgets(
    'already paired integration still warns about denied notifications',
    (tester) async {
      pushService.alreadyPaired = true;
      pushService.status.value = PushNotificationStatus.permissionDenied;
      await tester.pumpWidget(host());
      incoming.value = Uri.https(
        'autogram.slovensko.digital',
        '/api/v1/qr-code-register',
        {'integration': 'pairing-token'},
      );
      await tester.pumpAndSettle();
      expect(
        find.text(strings.pairIntegrationNotificationsDeniedMessage),
        findsOneWidget,
      );
      expect(pushService.pairings, 0);
    },
  );

  testWidgets('renewing registration requires warning before pairing', (
    tester,
  ) async {
    pushService.status.value = PushNotificationStatus.registrationExpired;
    await tester.pumpWidget(host());
    incoming.value = Uri.https(
      'autogram.slovensko.digital',
      '/api/v1/qr-code-register',
      {'integration': 'pairing-token'},
    );
    await tester.pumpAndSettle();
    expect(
      find.text(strings.pairingRenewalConfirmationMessage),
      findsOneWidget,
    );
    expect(pushService.pairings, 0);

    await tester.tap(
      find.text(strings.notificationPermissionRationaleDeclineLabel),
    );
    await tester.pumpAndSettle();
    expect(pushService.pairings, 0);
  });

  testWidgets(
    'registration warning remains visible until registration is restored',
    (tester) async {
      pushService.status.value = PushNotificationStatus.registrationExpired;
      await tester.pumpWidget(host());
      expect(find.text(strings.pairingRenewalRequiredMessage), findsOneWidget);

      pushService.status.value = PushNotificationStatus.ready;
      await tester.pumpAndSettle();
      expect(find.text(strings.pairingRenewalRequiredMessage), findsNothing);
    },
  );

  testWidgets('unavailable status banner exposes retry action', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PushNotificationStatusBanner(
            status: PushNotificationStatus.unavailable,
            onRetry: () => retries++,
          ),
        ),
      ),
    );
    expect(
      find.text(strings.notificationStatusUnavailableMessage),
      findsOneWidget,
    );
    await tester.tap(find.text(strings.buttonRetryLabel));
    expect(retries, 1);
  });

  testWidgets(
    'paired devices show expired registration above the old pairings',
    (tester) async {
      pushService.status.value = PushNotificationStatus.registrationExpired;
      getIt.registerFactory<PairedDeviceListCubit>(() => _PairedDevicesCubit());
      await tester.pumpWidget(host());
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const PairedDeviceListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(strings.pairingRenewalRequiredMessage), findsOneWidget);
      expect(find.text('Previously paired browser'), findsOneWidget);
    },
  );
}

class _Api extends Fake implements IAutogramService {}

class _PreviewCubit extends PreviewDocumentCubit {
  _PreviewCubit(String id) : super(service: _Api(), documentId: id);

  @override
  Future<void> getVisualization() async {
    emit(state.toError(StateError('No preview in this test')));
  }
}

class _ValidationCubit extends DocumentValidationCubit {
  _ValidationCubit() : super(service: _Api());

  @override
  Future<void> validateDocument(String documentId) async {
    emit(const DocumentValidationNotSignedState());
  }
}

class _PushService extends Fake implements PushNotificationService {
  @override
  final ValueNotifier<PushNotificationStatus> status = ValueNotifier(
    PushNotificationStatus.notRegistered,
  );
  bool alreadyPaired = false;
  int pairings = 0;

  @override
  Future<void> refreshStatus({String? registrationId}) async {}

  @override
  Future<bool> isIntegrationPaired(String pairingToken) async => alreadyPaired;

  @override
  Future<bool> pairIntegration(String pairingToken) async {
    pairings++;
    status.value = PushNotificationStatus.permissionDenied;
    return false;
  }
}

class _PairedDevicesCubit extends PairedDeviceListCubit {
  _PairedDevicesCubit() : super(service: _Api(), deviceRegistry: _Registry());

  @override
  Future<void> load() async {
    emit(
      state.toSuccess([
        const GetDeviceIntegrationsResponseBody$Item(
          integrationId: 'integration',
          platform: 'extension',
          displayName: 'Previously paired browser',
        ),
      ]),
    );
  }
}

class _Registry extends Fake implements DeviceRegistry {}
