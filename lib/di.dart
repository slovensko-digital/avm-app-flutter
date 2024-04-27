import 'package:autogram_sign/autogram_sign.dart';
import 'package:eidmsdk/eidmsdk.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';
import 'services/encryption_key_registry.dart';

final getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: true)
void configureDependencies() {
  getIt.init();

  // Manually register external types
  getIt.registerLazySingleton<IAutogramService>(
    () {
      final encryptionKeyRegistry = getIt.get<EncryptionKeyRegistry>();

      return AutogramService(
        encryptionKeySource: () => encryptionKeyRegistry.value,
      );
    },
  );

  getIt.registerLazySingleton<Eidmsdk>(
    () => Eidmsdk(),
  );
}
