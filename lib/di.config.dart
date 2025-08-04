// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;
import 'dart:io' as _i497;

import 'package:autogram_sign/autogram_sign.dart' as _i825;
import 'package:eidmsdk/eidmsdk.dart' as _i713;
import 'package:eidmsdk/types.dart' as _i518;
import 'package:flutter/foundation.dart' as _i971;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'app_service.dart' as _i403;
import 'bloc/create_document_cubit.dart' as _i374;
import 'bloc/document_validation_cubit.dart' as _i205;
import 'bloc/get_document_signature_type_cubit.dart' as _i767;
import 'bloc/paired_device_list_cubit.dart' as _i578;
import 'bloc/present_signed_document_cubit.dart' as _i687;
import 'bloc/preview_document_cubit.dart' as _i21;
import 'bloc/select_signing_certificate_cubit.dart' as _i1033;
import 'bloc/sign_document_cubit.dart' as _i520;
import 'data/document_signing_type.dart' as _i873;
import 'data/pdf_signing_option.dart' as _i732;
import 'di.dart' as _i913;
import 'services/encryption_key_registry.dart' as _i429;
import 'use_case/get_document_signature_type_use_case.dart' as _i400;
import 'use_case/get_html_document_version_use_case.dart' as _i752;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final extrernalModule = _$ExtrernalModule();
    gh.singleton<_i403.AppService>(() => _i403.AppService());
    gh.singleton<_i429.EncryptionKeyRegistry>(
        () => _i429.EncryptionKeyRegistry());
    gh.lazySingleton<_i752.GetHtmlDocumentVersionUseCase>(
        () => _i752.GetHtmlDocumentVersionUseCase());
    gh.lazySingleton<_i713.Eidmsdk>(() => extrernalModule.eidmsdk);
    gh.lazySingleton<_i825.IAutogramService>(
        () => extrernalModule.create(gh<_i429.EncryptionKeyRegistry>()));
    gh.factoryParam<_i687.PresentSignedDocumentCubit,
        _i825.SignDocumentResponseBody, _i873.DocumentSigningType>((
      signedDocument,
      signingType,
    ) =>
        _i687.PresentSignedDocumentCubit(
          appService: gh<_i403.AppService>(),
          signedDocument: signedDocument,
          signingType: signingType,
        ));
    gh.factoryParam<_i374.CreateDocumentCubit, _i687.FutureOr<_i497.File>,
        _i732.PdfSigningOption>((
      file,
      pdfSigningOption,
    ) =>
        _i374.CreateDocumentCubit(
          service: gh<_i825.IAutogramService>(),
          file: file,
          pdfSigningOption: pdfSigningOption,
        ));
    gh.factoryParam<_i520.SignDocumentCubit, String, _i518.Certificate>((
      documentId,
      certificate,
    ) =>
        _i520.SignDocumentCubit(
          service: gh<_i825.IAutogramService>(),
          eidmsdk: gh<_i713.Eidmsdk>(),
          documentId: documentId,
          certificate: certificate,
        ));
    gh.factoryParam<_i1033.SelectSigningCertificateCubit,
        _i971.ValueNotifier<_i518.Certificate?>, dynamic>((
      signingCertificate,
      _,
    ) =>
        _i1033.SelectSigningCertificateCubit(
          eidmsdk: gh<_i713.Eidmsdk>(),
          signingCertificate: signingCertificate,
        ));
    gh.factory<_i205.DocumentValidationCubit>(() =>
        _i205.DocumentValidationCubit(service: gh<_i825.IAutogramService>()));
    gh.factory<_i578.PairedDeviceListCubit>(() =>
        _i578.PairedDeviceListCubit(service: gh<_i825.IAutogramService>()));
    gh.lazySingleton<_i400.GetDocumentSignatureTypeUseCase>(() =>
        _i400.GetDocumentSignatureTypeUseCase(gh<_i825.IAutogramService>()));
    gh.factoryParam<_i21.PreviewDocumentCubit, String, dynamic>((
      documentId,
      _,
    ) =>
        _i21.PreviewDocumentCubit(
          service: gh<_i825.IAutogramService>(),
          documentId: documentId,
        ));
    gh.factory<_i767.GetDocumentSignatureTypeCubit>(() =>
        _i767.GetDocumentSignatureTypeCubit(
            getDocumentSignatureType:
                gh<_i400.GetDocumentSignatureTypeUseCase>()));
    return this;
  }
}

class _$ExtrernalModule extends _i913.ExtrernalModule {
  @override
  _i713.Eidmsdk get eidmsdk => _i713.Eidmsdk();
}
