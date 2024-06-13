// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i16;
import 'dart:io' as _i17;

import 'package:autogram_sign/autogram_sign.dart' as _i7;
import 'package:eidmsdk/eidmsdk.dart' as _i4;
import 'package:eidmsdk/types.dart' as _i13;
import 'package:flutter/foundation.dart' as _i12;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'app_service.dart' as _i3;
import 'bloc/create_document_cubit.dart' as _i15;
import 'bloc/get_document_parameters_cubit.dart' as _i19;
import 'bloc/paired_device_list_cubit.dart' as _i8;
import 'bloc/present_signed_document_cubit.dart' as _i9;
import 'bloc/preview_document_cubit.dart' as _i10;
import 'bloc/select_signing_certificate_cubit.dart' as _i11;
import 'bloc/sign_document_cubit.dart' as _i14;
import 'data/pdf_signing_option.dart' as _i18;
import 'di.dart' as _i20;
import 'services/encryption_key_registry.dart' as _i5;
import 'use_case/get_document_version_use_case.dart' as _i6;

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
    final extrernalModule = _$ExtrernalModule();
    gh.singleton<_i3.AppService>(() => _i3.AppService());
    gh.lazySingleton<_i4.Eidmsdk>(() => extrernalModule.eidmsdk);
    gh.singleton<_i5.EncryptionKeyRegistry>(() => _i5.EncryptionKeyRegistry());
    gh.lazySingleton<_i6.GetDocumentVersionUseCase>(
        () => _i6.GetDocumentVersionUseCase());
    gh.lazySingleton<_i7.IAutogramService>(
        () => extrernalModule.create(gh<_i5.EncryptionKeyRegistry>()));
    gh.factory<_i8.PairedDeviceListCubit>(
        () => _i8.PairedDeviceListCubit(service: gh<_i7.IAutogramService>()));
    gh.factoryParam<_i9.PresentSignedDocumentCubit,
        _i7.SignDocumentResponseBody, dynamic>((
      signedDocument,
      _,
    ) =>
        _i9.PresentSignedDocumentCubit(
          appService: gh<_i3.AppService>(),
          signedDocument: signedDocument,
        ));
    gh.factoryParam<_i10.PreviewDocumentCubit, String, dynamic>((
      documentId,
      _,
    ) =>
        _i10.PreviewDocumentCubit(
          service: gh<_i7.IAutogramService>(),
          documentId: documentId,
        ));
    gh.factoryParam<_i11.SelectSigningCertificateCubit,
        _i12.ValueNotifier<_i13.Certificate?>, dynamic>((
      signingCertificate,
      _,
    ) =>
        _i11.SelectSigningCertificateCubit(
          eidmsdk: gh<_i4.Eidmsdk>(),
          signingCertificate: signingCertificate,
        ));
    gh.factoryParam<_i14.SignDocumentCubit, String, _i13.Certificate>((
      documentId,
      certificate,
    ) =>
        _i14.SignDocumentCubit(
          service: gh<_i7.IAutogramService>(),
          eidmsdk: gh<_i4.Eidmsdk>(),
          documentId: documentId,
          certificate: certificate,
        ));
    gh.factoryParam<_i15.CreateDocumentCubit, _i16.FutureOr<_i17.File>,
        _i18.PdfSigningOption>((
      file,
      pdfSigningOption,
    ) =>
        _i15.CreateDocumentCubit(
          service: gh<_i7.IAutogramService>(),
          file: file,
          pdfSigningOption: pdfSigningOption,
        ));
    gh.factory<_i19.GetDocumentParametersCubit>(() =>
        _i19.GetDocumentParametersCubit(
            autogramService: gh<_i7.IAutogramService>()));
    return this;
  }
}

class _$ExtrernalModule extends _i20.ExtrernalModule {
  @override
  _i4.Eidmsdk get eidmsdk => _i4.Eidmsdk();
}
