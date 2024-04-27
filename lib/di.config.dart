// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:io' as _i6;

import 'package:autogram_sign/autogram_sign.dart' as _i8;
import 'package:eidmsdk/eidmsdk.dart' as _i16;
import 'package:eidmsdk/types.dart' as _i15;
import 'package:flutter/foundation.dart' as _i14;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'app_service.dart' as _i3;
import 'bloc/create_document_cubit.dart' as _i4;
import 'bloc/paired_device_list_cubit.dart' as _i10;
import 'bloc/present_signed_document_cubit.dart' as _i11;
import 'bloc/preview_document_cubit.dart' as _i12;
import 'bloc/select_signing_certificate_cubit.dart' as _i13;
import 'bloc/sign_document_cubit.dart' as _i17;
import 'data/pdf_signing_option.dart' as _i7;
import 'services/encryption_key_registry.dart' as _i9;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i3.AppService>(() => _i3.AppService());
    gh.factoryParam<_i4.CreateDocumentCubit, _i5.FutureOr<_i6.File>,
        _i7.PdfSigningOption>((
      file,
      pdfSigningOption,
    ) =>
        _i4.CreateDocumentCubit(
          service: gh<_i8.IAutogramService>(),
          file: file,
          pdfSigningOption: pdfSigningOption,
        ));
    gh.singleton<_i9.EncryptionKeyRegistry>(() => _i9.EncryptionKeyRegistry());
    gh.factory<_i10.PairedDeviceListCubit>(
        () => _i10.PairedDeviceListCubit(service: gh<_i8.IAutogramService>()));
    gh.factoryParam<_i11.PresentSignedDocumentCubit,
        _i8.SignDocumentResponseBody, dynamic>((
      signedDocument,
      _,
    ) =>
        _i11.PresentSignedDocumentCubit(
          appService: gh<_i3.AppService>(),
          signedDocument: signedDocument,
        ));
    gh.factoryParam<_i12.PreviewDocumentCubit, String, dynamic>((
      documentId,
      _,
    ) =>
        _i12.PreviewDocumentCubit(
          service: gh<_i8.IAutogramService>(),
          documentId: documentId,
        ));
    gh.factoryParam<_i13.SelectSigningCertificateCubit,
        _i14.ValueNotifier<_i15.Certificate?>, dynamic>((
      signingCertificate,
      _,
    ) =>
        _i13.SelectSigningCertificateCubit(
          eidmsdk: gh<_i16.Eidmsdk>(),
          signingCertificate: signingCertificate,
        ));
    gh.factoryParam<_i17.SignDocumentCubit, String, _i15.Certificate>((
      documentId,
      certificate,
    ) =>
        _i17.SignDocumentCubit(
          service: gh<_i8.IAutogramService>(),
          eidmsdk: gh<_i16.Eidmsdk>(),
          documentId: documentId,
          certificate: certificate,
        ));
    return this;
  }
}
