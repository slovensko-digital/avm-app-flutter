import 'package:eidmsdk/eidmsdk.dart';
import 'package:eidmsdk/eidmsdk_platform_interface.dart';
import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../ui/screens/select_certificate_screen.dart';
import 'select_certificate_state.dart';

export 'select_certificate_state.dart';

/// Cubit for the [SelectCertificateScreen].
@injectable
class SelectCertificateCubit extends Cubit<SelectCertificateState> {
  static final _log = Logger("SelectCertificateCubit");
  static const _defaultLanguage = 'sk';

  final Eidmsdk _eidmsdk;
  final ValueNotifier<Certificate?> _signingCertificate;

  SelectCertificateCubit({
    required Eidmsdk eidmsdk,
    @factoryParam required ValueNotifier<Certificate?> signingCertificate,
  })  : _eidmsdk = eidmsdk,
        _signingCertificate = signingCertificate,
        super(const SelectCertificateInitialState());

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
      emit(state.toSuccess(certificate));
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
          emit(state.toSuccess(certificate));
        }
      }
    } catch (error, stackTrace) {
      _log.severe("Error getting Certificates.", error, stackTrace);

      emit(state.toError(error));
    }
  }
}
