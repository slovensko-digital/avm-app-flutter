import 'package:autogram_sign/autogram_sign.dart';
import 'package:eidmsdk/eidmsdk.dart';
import 'package:eidmsdk/eidmsdk_platform_interface.dart';
import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../data/signature_type.dart';
import '../ui/fragment/select_signing_certificate_fragment.dart';
import 'select_signing_certificate_state.dart';

export 'select_signing_certificate_state.dart';

/// Cubit for the [SelectSigningCertificateFragment].
@injectable
class SelectSigningCertificateCubit
    extends Cubit<SelectSigningCertificateState> {
  static final _log = Logger((SelectSigningCertificateCubit).toString());
  static const _defaultLanguage = 'sk';

  final Eidmsdk _eidmsdk;
  final IAutogramService _autogramService;
  final ValueNotifier<Certificate?> _signingCertificate;
  SignatureType? _signatureType;

  SelectSigningCertificateCubit({
    required Eidmsdk eidmsdk,
    required IAutogramService autogramService,
    @factoryParam required ValueNotifier<Certificate?> signingCertificate,
  })  : _eidmsdk = eidmsdk,
        _autogramService = autogramService,
        _signingCertificate = signingCertificate,
        super(const SelectSigningCertificateInitialState());

  /// Loads the Document parameters needed to preset [SignatureType].
  Future<void> loadDocumentParameters(String documentId) async {
    emit(state.toLoading());

    try {
      final params = await _autogramService.getDocumentParameters(documentId);
      final SignatureType? signatureType = switch (params.level) {
        null => null,
        SigningParametersLevel.cadesBaselineT => SignatureType.withTimestamp,
        SigningParametersLevel.padesBaselineT => SignatureType.withTimestamp,
        SigningParametersLevel.xadesBaselineT => SignatureType.withTimestamp,
        _ => SignatureType.withoutTimestamp
      };

      _log.info(
          "Got Document Parameters; Signature Type is: ${signatureType?.name}.");

      _signatureType = signatureType;

      // TODO Use separate state
      emit(const SelectSigningCertificateInitialState());
    } catch (error, stackTrace) {
      _log.severe("Error getting Document Parameters.", error, stackTrace);

      emit(state.toError(error));
    }
  }

  /// Gets the certificates.
  ///
  /// When [refresh] is `true`, then [_signingCertificate] is cleared.
  /// When [_signingCertificate] is non-`null`, then it's used and SDK call is skipped.
  Future<void> getCertificates({bool refresh = false}) async {
    emit(state.toLoading());

    if (refresh) {
      _signingCertificate.value = null;
    }

    final certificate = _signingCertificate.value;

    if (certificate != null) {
      emit(state.toSuccess(certificate, _signatureType));
      return;
    }

    try {
      final certificates = await _eidmsdk.getCertificates(
        types: const [EIDCertificateIndex.qes],
        language: _defaultLanguage,
      );

      _log.info("Got Certificates: ${certificates?.runtimeType}.");

      // Will be null when it's cancelled by user
      if (certificates == null) {
        emit(state.toCanceled());
      } else {
        // Taking 1st QES cert.
        final certificate = certificates.certificates.firstOrNull;

        if (certificate == null) {
          emit(state.toNoCertificate());
        } else {
          // TODO Copy "_signatureType" and certificate between states
          emit(state.toSuccess(certificate, _signatureType));
        }
      }
    } catch (error, stackTrace) {
      _log.severe("Error getting Certificates.", error, stackTrace);

      emit(state.toError(error));
    }
  }
}
