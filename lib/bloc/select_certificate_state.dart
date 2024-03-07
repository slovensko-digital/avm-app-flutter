import 'package:eidmsdk/types.dart';
import 'package:flutter/foundation.dart';

import 'select_certificate_cubit.dart';

/// State for [SelectCertificateCubit].
@immutable
sealed class SelectCertificateState {
  const SelectCertificateState();

  SelectCertificateLoadingState toLoading() {
    return const SelectCertificateLoadingState();
  }

  SelectCertificateErrorState toError(Object error) {
    return SelectCertificateErrorState(error);
  }

  SelectCertificateSuccessState toSuccess(CertificatesInfo certificates) {
    return SelectCertificateSuccessState(certificates);
  }

  SelectCertificateCanceledState toCanceledState() {
    return const SelectCertificateCanceledState();
  }

  @override
  String toString() {
    return "$runtimeType()";
  }
}

class SelectCertificateInitialState extends SelectCertificateState {
  const SelectCertificateInitialState();
}

class SelectCertificateLoadingState extends SelectCertificateState {
  const SelectCertificateLoadingState();
}

class SelectCertificateErrorState extends SelectCertificateState {
  final Object error;

  const SelectCertificateErrorState(this.error);

  @override
  String toString() {
    return "$runtimeType(error: $error)";
  }
}

class SelectCertificateCanceledState extends SelectCertificateState {
  const SelectCertificateCanceledState();
}

class SelectCertificateSuccessState extends SelectCertificateState {
  final CertificatesInfo certificates;

  const SelectCertificateSuccessState(this.certificates);

  @override
  String toString() {
    return "$runtimeType(certificates: $certificates)";
  }
}
