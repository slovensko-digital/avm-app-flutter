import 'package:autogram_sign/autogram_sign.dart';
import 'package:injectable/injectable.dart';

import '../data/avm_server.dart';
import 'encryption_key_registry.dart';

/// Provides [IAutogramService] for the [AvmServer], which stores the document.
@lazySingleton
class AutogramServices {
  final IAutogramService _official;
  final EncryptionKeyRegistry _encryptionKeyRegistry;
  final _services = <AvmServer, IAutogramService>{};

  AutogramServices(this._official, this._encryptionKeyRegistry);

  /// Gets [IAutogramService] for the [server].
  ///
  /// Service for other than the official server doesn't authenticate this
  /// device, as the device is registered only on the official server.
  IAutogramService of(AvmServer server) {
    if (server.isOfficial) {
      return _official;
    }

    return _services.putIfAbsent(server, () {
      return AutogramService(
        baseUrl: server.baseUrl,
        encryptionKeySource: () => _encryptionKeyRegistry.value,
      );
    });
  }
}
