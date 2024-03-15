// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:autogram/ui/app_theme.dart' as _i3;
import 'package:autogram/ui/screens/main_screen.dart' as _i2;
import 'package:autogram/ui/screens/present_signed_document_screen.dart'
    as _i14;
import 'package:autogram/ui/screens/select_certificate_screen.dart' as _i15;
import 'package:autogram/ui/screens/settings_screen.dart' as _i16;
import 'package:autogram/ui/widgets/autogram_logo.dart' as _i4;
import 'package:autogram/ui/widgets/document_visualization.dart' as _i6;
import 'package:autogram/ui/widgets/error_content.dart' as _i7;
import 'package:autogram/ui/widgets/loading_content.dart' as _i8;
import 'package:autogram/ui/widgets/loading_indicator.dart' as _i5;
import 'package:autogram/ui/widgets/option_picker.dart' as _i9;
import 'package:autogram/ui/widgets/preference_tile.dart' as _i10;
import 'package:autogram/ui/widgets/result_view.dart' as _i11;
import 'package:autogram/ui/widgets/retry_view.dart' as _i12;
import 'package:autogram/ui/widgets/signature_type_picker.dart' as _i13;
import 'package:widgetbook/widgetbook.dart' as _i1;

final directories = <_i1.WidgetbookNode>[
  _i1.WidgetbookCategory(
    name: 'AVM',
    children: [
      _i1.WidgetbookComponent(
        name: 'AppBar',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'main',
            builder: _i2.previewMainAppBar,
          ),
          _i1.WidgetbookUseCase(
            name: 'normal',
            builder: _i3.previewAppBar,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'AutogramLogo',
        useCase: _i1.WidgetbookUseCase(
          name: 'AutogramLogo',
          builder: _i4.previewAutogramLogo,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'Button',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'filled',
            builder: _i3.previewFilledButton,
          ),
          _i1.WidgetbookUseCase(
            name: 'text',
            builder: _i3.previewTextButton,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'LoadingIndicator',
        useCase: _i1.WidgetbookUseCase(
          name: 'LoadingIndicator',
          builder: _i5.previewLoadingIndicator,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'Radio',
        useCase: _i1.WidgetbookUseCase(
          name: 'Radio',
          builder: _i3.previewRadio,
        ),
      ),
    ],
  ),
  _i1.WidgetbookCategory(
    name: 'Core',
    children: [
      _i1.WidgetbookLeafComponent(
        name: 'DocumentVisualization',
        useCase: _i1.WidgetbookUseCase(
          name: 'DocumentVisualization',
          builder: _i6.previewDocumentVisualization,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'ErrorContent',
        useCase: _i1.WidgetbookUseCase(
          name: 'ErrorContent',
          builder: _i7.previewErrorContent,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'LoadingContent',
        useCase: _i1.WidgetbookUseCase(
          name: 'LoadingContent',
          builder: _i8.previewLoadingContent,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'OptionPicker',
        useCase: _i1.WidgetbookUseCase(
          name: 'OptionPicker',
          builder: _i9.previewOptionPicker,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'PreferenceTile',
        useCase: _i1.WidgetbookUseCase(
          name: 'PreferenceTile',
          builder: _i10.previewPreferenceTile,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'ResultView',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i11.previewErrorResultView,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i11.previewSuccessResultView,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'RetryView',
        useCase: _i1.WidgetbookUseCase(
          name: 'RetryView',
          builder: _i12.previewRetryView,
        ),
      ),
    ],
  ),
  _i1.WidgetbookCategory(
    name: 'Lists',
    children: [
      _i1.WidgetbookLeafComponent(
        name: 'SignatureTypePicker',
        useCase: _i1.WidgetbookUseCase(
          name: 'SignatureTypePicker',
          builder: _i13.previewSignatureTypePicker,
        ),
      )
    ],
  ),
  _i1.WidgetbookCategory(
    name: 'Screens',
    children: [
      _i1.WidgetbookLeafComponent(
        name: 'MainBody',
        useCase: _i1.WidgetbookUseCase(
          name: 'MainBody',
          builder: _i2.previewMainBody,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'PresentSignedDocumentBody',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i14.previewErrorPresentSignedDocumentBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i14.previewLoadingPresentSignedDocumentBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i14.previewSuccessPresentSignedDocumentBody,
          ),
        ],
      ),
      _i1.WidgetbookComponent(
        name: 'SelectCertificateBody',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'canceled',
            builder: _i15.previewCanceledSelectCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i15.previewErrorCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i15.previewLoadingSelectCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'no certificate',
            builder: _i15.previewNoCertificateCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i15.previewSuccessCertificateCertificateBody,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'SettingsScreen',
        useCase: _i1.WidgetbookUseCase(
          name: 'SettingsScreen',
          builder: _i16.previewSettingsScreen,
        ),
      ),
    ],
  ),
];
