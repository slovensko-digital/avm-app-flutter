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
}

/// Injectable module for external 3rd party types, that are not annotated
/// by [injectable].
@module
abstract class ExtrernalModule {
  @lazySingleton
  Eidmsdk get eidmsdk;

  @lazySingleton
  IAutogramService create(EncryptionKeyRegistry encryptionKeyRegistry) {
    return AutogramService(
      encryptionKeySource: () => encryptionKeyRegistry.value,
    );
  }
}
