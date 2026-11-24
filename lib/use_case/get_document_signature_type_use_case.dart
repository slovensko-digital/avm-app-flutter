import 'package:autogram_sign/autogram_sign.dart' show SigningParametersLevel;
import 'package:injectable/injectable.dart' show lazySingleton;

import '../data/server_document.dart';
import '../data/signature_type.dart';
import '../services/autogram_services.dart';

/// Gets the Document [SignatureType].
@lazySingleton
class GetDocumentSignatureTypeUseCase {
  final AutogramServices services;

  GetDocumentSignatureTypeUseCase(this.services);

  /// Gets the [SignatureType] of the [document].
  Future<SignatureType?> call(ServerDocument document) async {
    final params = await services
        .of(document.server)
        .getDocumentParameters(document.id);

    return switch (params.level) {
      null => null,
      SigningParametersLevel.cadesBaselineT => SignatureType.withTimestamp,
      SigningParametersLevel.padesBaselineT => SignatureType.withTimestamp,
      SigningParametersLevel.xadesBaselineT => SignatureType.withTimestamp,
      _ => SignatureType.withoutTimestamp
    };
  }
}
