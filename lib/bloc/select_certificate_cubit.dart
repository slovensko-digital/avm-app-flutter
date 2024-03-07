import 'package:eidmsdk/eidmsdk.dart';
import 'package:eidmsdk/eidmsdk_platform_interface.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import 'select_certificate_state.dart';

export 'select_certificate_state.dart';

/// Cubit for the [SelectCertificateScreen].
@injectable
class SelectCertificateCubit extends Cubit<SelectCertificateState> {
  static final _log = Logger("SelectCertificateCubit");
  static const _defaultLanguage = 'sk';

  final Eidmsdk _eidmsdk;

  SelectCertificateCubit({
    required Eidmsdk eidmsdk,
  })  : _eidmsdk = eidmsdk,
        super(const SelectCertificateInitialState());

  /// Gets the certificates.
  Future<void> getCertificates() async {
    emit(state.toLoading());

    try {
      final certificates = await _eidmsdk.getCertificates(
        types: const [EIDCertificateIndex.qes],
        language: _defaultLanguage,
      );

      // Will be null when it's cancelled by user
      if (certificates == null) {
        emit(state.toCanceledState());
      } else {
        emit(state.toSuccess(certificates));
      }

      _log.info("Got Certificates: ${certificates?.runtimeType}.");
    } catch (error) {
      emit(state.toError(error));
    }
  }
}
