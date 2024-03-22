// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:autogram/ui/app_theme.dart' as _i3;
import 'package:autogram/ui/fragment/show_web_page_fragment.dart' as _i14;
import 'package:autogram/ui/screens/main_screen.dart' as _i2;
import 'package:autogram/ui/screens/onboarding_accept_terms_of_service_screen.dart'
    as _i17;
import 'package:autogram/ui/screens/onboarding_finished_screen.dart' as _i18;
import 'package:autogram/ui/screens/onboarding_select_signing_certificate_screen.dart'
    as _i19;
import 'package:autogram/ui/screens/open_document_screen.dart' as _i20;
import 'package:autogram/ui/screens/present_signed_document_screen.dart'
    as _i21;
import 'package:autogram/ui/screens/preview_document_screen.dart' as _i22;
import 'package:autogram/ui/screens/select_certificate_screen.dart' as _i23;
import 'package:autogram/ui/screens/settings_screen.dart' as _i24;
import 'package:autogram/ui/screens/sign_document_screen.dart' as _i25;
import 'package:autogram/ui/widgets/autogram_logo.dart' as _i4;
import 'package:autogram/ui/widgets/certificate_picker.dart' as _i15;
import 'package:autogram/ui/widgets/document_visualization.dart' as _i6;
import 'package:autogram/ui/widgets/error_content.dart' as _i7;
import 'package:autogram/ui/widgets/loading_content.dart' as _i8;
import 'package:autogram/ui/widgets/loading_indicator.dart' as _i5;
import 'package:autogram/ui/widgets/option_picker.dart' as _i9;
import 'package:autogram/ui/widgets/preference_tile.dart' as _i10;
import 'package:autogram/ui/widgets/result_view.dart' as _i11;
import 'package:autogram/ui/widgets/retry_view.dart' as _i12;
import 'package:autogram/ui/widgets/signature_type_picker.dart' as _i16;
import 'package:autogram/ui/widgets/step_indicator.dart' as _i13;
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
        name: 'Dialog',
        useCase: _i1.WidgetbookUseCase(
          name: 'Dialog',
          builder: _i3.previewDialog,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'LoadingIndicator',
        useCase: _i1.WidgetbookUseCase(
          name: 'LoadingIndicator',
          builder: _i5.previewLoadingIndicator,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'MaterialBanner',
        useCase: _i1.WidgetbookUseCase(
          name: 'MaterialBanner ',
          builder: _i3.previewMaterialBanner,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'Radio',
        useCase: _i1.WidgetbookUseCase(
          name: 'Radio',
          builder: _i3.previewRadio,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'SnackBar',
        useCase: _i1.WidgetbookUseCase(
          name: 'SnackBar',
          builder: _i3.previewSnackBar,
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
            name: 'info',
            builder: _i11.previewInfoResultView,
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
      _i1.WidgetbookLeafComponent(
        name: 'StepIndicator',
        useCase: _i1.WidgetbookUseCase(
          name: 'StepIndicator',
          builder: _i13.previewStepIndicator,
        ),
      ),
    ],
  ),
  _i1.WidgetbookCategory(
    name: 'Fragments',
    children: [
      _i1.WidgetbookLeafComponent(
        name: 'ShowWebPageFragment',
        useCase: _i1.WidgetbookUseCase(
          name: 'ShowWebPageFragment',
          builder: _i14.previewShowWebPageFragment,
        ),
      )
    ],
  ),
  _i1.WidgetbookCategory(
    name: 'Lists',
    children: [
      _i1.WidgetbookLeafComponent(
        name: 'CertificatePicker',
        useCase: _i1.WidgetbookUseCase(
          name: 'CertificatePicker',
          builder: _i15.previewCertificatePicker,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'SignatureTypePicker',
        useCase: _i1.WidgetbookUseCase(
          name: 'SignatureTypePicker',
          builder: _i16.previewSignatureTypePicker,
        ),
      ),
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
      _i1.WidgetbookLeafComponent(
        name: 'OnboardingAcceptTermsOfServiceScreen',
        useCase: _i1.WidgetbookUseCase(
          name: 'OnboardingAcceptTermsOfServiceScreen',
          builder: _i17.previewOnboardingAcceptTermsOfServiceScreen,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'OnboardingFinishedScreen',
        useCase: _i1.WidgetbookUseCase(
          name: 'OnboardingFinishedScreen',
          builder: _i18.previewOnboardingFinishedScreen,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'OnboardingSelectSigningCertificateScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'canceled',
            builder: _i19.previewCanceledOnboardingSelectSigningCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'initial',
            builder: _i19.previewInitialOnboardingSelectSigningCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'no certificate',
            builder:
                _i19.previewNoCertificateOnboardingSelectSigningCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i19.previewSuccessOnboardingSelectSigningCertificateBody,
          ),
        ],
      ),
      _i1.WidgetbookComponent(
        name: 'OpenDocumentScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i20.previewErrorOpenDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i20.previewLoadingOpenDocumentScreen,
          ),
        ],
      ),
      _i1.WidgetbookComponent(
        name: 'PresentSignedDocumentBody',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i21.previewErrorPresentSignedDocumentBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i21.previewLoadingPresentSignedDocumentBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i21.previewSuccessPresentSignedDocumentBody,
          ),
        ],
      ),
      _i1.WidgetbookComponent(
        name: 'PreviewDocumentScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i22.previewErrorOpenDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i22.previewLoadingPreviewDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i22.previewSuccessOpenDocumentScreen,
          ),
        ],
      ),
      _i1.WidgetbookComponent(
        name: 'SelectCertificateBody',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'canceled',
            builder: _i23.previewCanceledSelectCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i23.previewErrorCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i23.previewLoadingSelectCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'no certificate',
            builder: _i23.previewNoCertificateCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i23.previewSuccessCertificateCertificateBody,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'SettingsScreen',
        useCase: _i1.WidgetbookUseCase(
          name: 'SettingsScreen',
          builder: _i24.previewSettingsScreen,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'SignDocumentScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i25.previewErrorSignDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i25.previewLoadingSignDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i25.previewSuccessSignDocumentScreen,
          ),
        ],
      ),
    ],
  ),
];
