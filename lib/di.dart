import 'package:autogram_sign/autogram_sign.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies() {
  getIt.init();

  final serviceUrl = Uri.parse("https://autogram.slovensko.digital/api/v1");

  getIt.registerLazySingleton<IAutogramService>(
    () => AutogramService(
      baseUrl: serviceUrl,
      // TODO Custom encryptionKey for this instance
      encryptionKey: 'encryptionKey',
    ),
  );
}
