import 'package:autogram_sign/autogram_sign.dart';
import 'package:eidmsdk/eidmsdk.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';
import 'utils.dart';

final getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: true)
void configureDependencies() {
  getIt.init();

  // Manually register external types
  getIt.registerLazySingleton<IAutogramService>(
    () {
      final serviceUrl = Uri.parse("https://autogram.slovensko.digital/api/v1");

      return AutogramService(
        baseUrl: serviceUrl,
        encryptionKey: Utils.createCryptoRandomString(),
      );
    },
  );

  getIt.registerLazySingleton<Eidmsdk>(
    () => Eidmsdk(),
  );
}
