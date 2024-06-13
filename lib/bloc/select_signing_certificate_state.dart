import 'package:eidmsdk/types.dart';
import 'package:flutter/foundation.dart';

import '../data/signature_type.dart';
import 'select_signing_certificate_cubit.dart';

/// State for [SelectSigningCertificateCubit].
@immutable
sealed class SelectSigningCertificateState {
  const SelectSigningCertificateState();

  SelectSigningCertificateLoadingState toLoading() =>
      const SelectSigningCertificateLoadingState();

  SelectSigningCertificateErrorState toError(Object error) =>
      SelectSigningCertificateErrorState(error);

  SelectSigningCertificateSuccessState toSuccess(
    Certificate certificate,
    SignatureType? signatureType,
  ) =>
      SelectSigningCertificateSuccessState(certificate, signatureType);

  SelectSigningCertificateCanceledState toCanceled() =>
      const SelectSigningCertificateCanceledState();

  SelectSigningCertificateNoCertificateState toNoCertificate() =>
      const SelectSigningCertificateNoCertificateState();

  @override
  String toString() {
    return "$runtimeType()";
  }
}

class SelectSigningCertificateInitialState
    extends SelectSigningCertificateState {
  const SelectSigningCertificateInitialState();
}

class SelectSigningCertificateLoadingState
    extends SelectSigningCertificateState {
  const SelectSigningCertificateLoadingState();
}

class SelectSigningCertificateErrorState extends SelectSigningCertificateState {
  final Object error;

  const SelectSigningCertificateErrorState(this.error);

  @override
  String toString() {
    return "$runtimeType(error: $error)";
  }
}

class SelectSigningCertificateCanceledState
    extends SelectSigningCertificateState {
  const SelectSigningCertificateCanceledState();
}

class SelectSigningCertificateNoCertificateState
    extends SelectSigningCertificateState {
  const SelectSigningCertificateNoCertificateState();
}

class SelectSigningCertificateSuccessState
    extends SelectSigningCertificateState {
  final Certificate certificate;
  final SignatureType? signatureType;

  const SelectSigningCertificateSuccessState(
    this.certificate, [
    this.signatureType,
  ]);

  @override
  String toString() {
    return "$runtimeType(certificate: $certificate, signatureType: $signatureType)";
  }
}
