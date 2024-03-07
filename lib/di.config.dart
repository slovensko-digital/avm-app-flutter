// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i4;

import 'package:autogram_sign/autogram_sign.dart' as _i5;
import 'package:eidmsdk/eidmsdk.dart' as _i9;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'bloc/create_document_cubit.dart' as _i3;
import 'bloc/present_signed_document_cubit.dart' as _i6;
import 'bloc/preview_document_cubit.dart' as _i7;
import 'bloc/select_certificate_cubit.dart' as _i8;
import 'bloc/sign_document_cubit.dart' as _i10;

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
    gh.factoryParam<_i3.CreateDocumentCubit, _i4.File, dynamic>((
      file,
      _,
    ) =>
        _i3.CreateDocumentCubit(
          service: gh<_i5.IAutogramService>(),
          file: file,
        ));
    gh.factoryParam<_i6.PresentSignedDocumentCubit, _i5.SignDocumentResponse,
        dynamic>((
      signedDocument,
      _,
    ) =>
        _i6.PresentSignedDocumentCubit(signedDocument: signedDocument));
    gh.factoryParam<_i7.PreviewDocumentCubit, String, dynamic>((
      documentId,
      _,
    ) =>
        _i7.PreviewDocumentCubit(
          service: gh<_i5.IAutogramService>(),
          documentId: documentId,
        ));
    gh.factory<_i8.SelectCertificateCubit>(
        () => _i8.SelectCertificateCubit(eidmsdk: gh<_i9.Eidmsdk>()));
    gh.factoryParam<_i10.SignDocumentCubit, String, dynamic>((
      documentId,
      _,
    ) =>
        _i10.SignDocumentCubit(
          service: gh<_i5.IAutogramService>(),
          eidmsdk: gh<_i9.Eidmsdk>(),
          documentId: documentId,
        ));
    return this;
  }
}
