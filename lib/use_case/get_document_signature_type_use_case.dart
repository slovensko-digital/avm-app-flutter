import 'package:autogram_sign/autogram_sign.dart'
    show IAutogramService, SigningParametersLevel;
import 'package:injectable/injectable.dart' show lazySingleton;

import '../data/signature_type.dart';

/// Gets the Document [SignatureType].
@lazySingleton
class GetDocumentSignatureTypeUseCase {
  final IAutogramService autogramService;

  GetDocumentSignatureTypeUseCase(this.autogramService);

  /// Gets the [SignatureType] of Document with given [documentId].
  Future<SignatureType?> call(String documentId) async {
    final params = await autogramService.getDocumentParameters(documentId);

    return switch (params.level) {
      null => null,
      SigningParametersLevel.cadesBaselineT => SignatureType.withTimestamp,
      SigningParametersLevel.padesBaselineT => SignatureType.withTimestamp,
      SigningParametersLevel.xadesBaselineT => SignatureType.withTimestamp,
      _ => SignatureType.withoutTimestamp
    };
  }
}
