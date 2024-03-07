// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:autogram/ui/screens/present_signed_document_screen.dart'
    as _i11;
import 'package:autogram/ui/widgets/autogram_logo.dart' as _i2;
import 'package:autogram/ui/widgets/certificate_picker.dart' as _i10;
import 'package:autogram/ui/widgets/document_visualization.dart' as _i3;
import 'package:autogram/ui/widgets/error_content.dart' as _i4;
import 'package:autogram/ui/widgets/loading_content.dart' as _i5;
import 'package:autogram/ui/widgets/option_picker.dart' as _i6;
import 'package:autogram/ui/widgets/preference_tile.dart' as _i7;
import 'package:autogram/ui/widgets/result_view.dart' as _i8;
import 'package:autogram/ui/widgets/retry_view.dart' as _i9;
import 'package:widgetbook/widgetbook.dart' as _i1;

final directories = <_i1.WidgetbookNode>[
  _i1.WidgetbookCategory(
    name: 'Core',
    children: [
      _i1.WidgetbookLeafComponent(
        name: 'AutogramLogo',
        useCase: _i1.WidgetbookUseCase(
          name: 'AutogramLogo',
          builder: _i2.previewAutogramLogo,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'DocumentVisualization',
        useCase: _i1.WidgetbookUseCase(
          name: 'DocumentVisualization',
          builder: _i3.previewDocumentVisualization,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'ErrorContent',
        useCase: _i1.WidgetbookUseCase(
          name: 'ErrorContent',
          builder: _i4.previewErrorContent,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'LoadingContent',
        useCase: _i1.WidgetbookUseCase(
          name: 'LoadingContent',
          builder: _i5.previewLoadingContent,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'OptionPicker',
        useCase: _i1.WidgetbookUseCase(
          name: 'OptionPicker',
          builder: _i6.previewOptionPicker,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'PreferenceTile',
        useCase: _i1.WidgetbookUseCase(
          name: 'PreferenceTile',
          builder: _i7.previewPreferenceTile,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'ResultView',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i8.previewErrorResultView,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i8.previewSuccessResultView,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'RetryView',
        useCase: _i1.WidgetbookUseCase(
          name: 'RetryView',
          builder: _i9.previewRetryView,
        ),
      ),
    ],
  ),
  _i1.WidgetbookCategory(
    name: 'Lists',
    children: [
      _i1.WidgetbookLeafComponent(
        name: 'CertificatePicker',
        useCase: _i1.WidgetbookUseCase(
          name: 'AutogramLogo',
          builder: _i10.previewCertificatePicker,
        ),
      )
    ],
  ),
  _i1.WidgetbookCategory(
    name: 'Screens',
    children: [
      _i1.WidgetbookComponent(
        name: 'PresentSignedDocumentBody',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i11.previewErrorPresentSignedDocumentBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i11.previewLoadingPresentSignedDocumentBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i11.previewSuccessPresentSignedDocumentBody,
          ),
        ],
      )
    ],
  ),
];
