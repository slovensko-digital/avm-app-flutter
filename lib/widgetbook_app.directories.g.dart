// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:autogram/ui/app_theme.dart' as _i3;
import 'package:autogram/ui/assets.dart' as _i4;
import 'package:autogram/ui/fragment/show_web_page_fragment.dart' as _i19;
import 'package:autogram/ui/screens/about_screen.dart' as _i22;
import 'package:autogram/ui/screens/main_menu_screen.dart' as _i23;
import 'package:autogram/ui/screens/main_screen.dart' as _i2;
import 'package:autogram/ui/screens/onboarding_accept_terms_of_service_screen.dart'
    as _i24;
import 'package:autogram/ui/screens/onboarding_finished_screen.dart' as _i25;
import 'package:autogram/ui/screens/onboarding_select_signing_certificate_screen.dart'
    as _i26;
import 'package:autogram/ui/screens/open_document_screen.dart' as _i27;
import 'package:autogram/ui/screens/paired_device_list_screen.dart' as _i28;
import 'package:autogram/ui/screens/present_signed_document_screen.dart'
    as _i29;
import 'package:autogram/ui/screens/preview_document_screen.dart' as _i30;
import 'package:autogram/ui/screens/select_certificate_screen.dart' as _i31;
import 'package:autogram/ui/screens/settings_screen.dart' as _i32;
import 'package:autogram/ui/screens/show_terms_of_service_screen.dart' as _i33;
import 'package:autogram/ui/screens/sign_document_screen.dart' as _i34;
import 'package:autogram/ui/screens/start_remote_document_signing_screen.dart'
    as _i35;
import 'package:autogram/ui/widgets/app_version_text.dart' as _i8;
import 'package:autogram/ui/widgets/autogram_logo.dart' as _i5;
import 'package:autogram/ui/widgets/certificate_picker.dart' as _i20;
import 'package:autogram/ui/widgets/close_button.dart' as _i6;
import 'package:autogram/ui/widgets/dialogs.dart' as _i18;
import 'package:autogram/ui/widgets/document_visualization.dart' as _i9;
import 'package:autogram/ui/widgets/error_content.dart' as _i10;
import 'package:autogram/ui/widgets/html_preview.dart' as _i11;
import 'package:autogram/ui/widgets/loading_content.dart' as _i12;
import 'package:autogram/ui/widgets/loading_indicator.dart' as _i7;
import 'package:autogram/ui/widgets/option_picker.dart' as _i13;
import 'package:autogram/ui/widgets/preference_tile.dart' as _i14;
import 'package:autogram/ui/widgets/result_view.dart' as _i15;
import 'package:autogram/ui/widgets/retry_view.dart' as _i16;
import 'package:autogram/ui/widgets/signature_type_picker.dart' as _i21;
import 'package:autogram/ui/widgets/step_indicator.dart' as _i17;
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
      _i1.WidgetbookComponent(
        name: 'Asset',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'icons',
            builder: _i4.previewIcons,
          ),
          _i1.WidgetbookUseCase(
            name: 'images',
            builder: _i4.previewImages,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'AutogramLogo',
        useCase: _i1.WidgetbookUseCase(
          name: 'AutogramLogo',
          builder: _i5.previewAutogramLogo,
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
        name: 'CloseButton',
        useCase: _i1.WidgetbookUseCase(
          name: 'CloseButton',
          builder: _i6.previewCloseButton,
        ),
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
          builder: _i7.previewLoadingIndicator,
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
        name: 'AppVersionText',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i8.previewAppVersionText,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'DocumentVisualization',
        useCase: _i1.WidgetbookUseCase(
          name: 'DocumentVisualization',
          builder: _i9.previewDocumentVisualization,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'ErrorContent',
        useCase: _i1.WidgetbookUseCase(
          name: 'ErrorContent',
          builder: _i10.previewErrorContent,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'HtmlPreview',
        useCase: _i1.WidgetbookUseCase(
          name: 'HtmlPreview',
          builder: _i11.previewHtmlPreview,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'LoadingContent',
        useCase: _i1.WidgetbookUseCase(
          name: 'LoadingContent',
          builder: _i12.previewLoadingContent,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'OptionPicker',
        useCase: _i1.WidgetbookUseCase(
          name: 'OptionPicker',
          builder: _i13.previewOptionPicker,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'PreferenceTile',
        useCase: _i1.WidgetbookUseCase(
          name: 'PreferenceTile',
          builder: _i14.previewPreferenceTile,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'ResultView',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'custom',
            builder: _i15.previewCustomResultView,
          ),
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i15.previewErrorResultView,
          ),
          _i1.WidgetbookUseCase(
            name: 'info',
            builder: _i15.previewInfoResultView,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i15.previewSuccessResultView,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'RetryView',
        useCase: _i1.WidgetbookUseCase(
          name: 'RetryView',
          builder: _i16.previewRetryView,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'StepIndicator',
        useCase: _i1.WidgetbookUseCase(
          name: 'StepIndicator',
          builder: _i17.previewStepIndicator,
        ),
      ),
    ],
  ),
  _i1.WidgetbookCategory(
    name: 'Dialogs',
    children: [
      _i1.WidgetbookLeafComponent(
        name: 'BottomSheet',
        useCase: _i1.WidgetbookUseCase(
          name: 'NotificationsPermissionRationale',
          builder: _i18.previewNotificationsPermissionRationaleModal,
        ),
      )
    ],
  ),
  _i1.WidgetbookCategory(
    name: 'Fragments',
    children: [
      _i1.WidgetbookLeafComponent(
        name: 'ShowWebPageFragment',
        useCase: _i1.WidgetbookUseCase(
          name: 'ShowWebPageFragment',
          builder: _i19.previewShowWebPageFragment,
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
          builder: _i20.previewCertificatePicker,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'SignatureTypePicker',
        useCase: _i1.WidgetbookUseCase(
          name: 'SignatureTypePicker',
          builder: _i21.previewSignatureTypePicker,
        ),
      ),
    ],
  ),
  _i1.WidgetbookCategory(
    name: 'Screens',
    children: [
      _i1.WidgetbookLeafComponent(
        name: 'AboutScreen',
        useCase: _i1.WidgetbookUseCase(
          name: 'AboutScreen',
          builder: _i22.previewAboutScreen,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'MainMenuScreen',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i23.previewMainMenuScreen,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'MainScreen',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i2.previewMainScreen,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'OnboardingAcceptTermsOfServiceScreen',
        useCase: _i1.WidgetbookUseCase(
          name: 'OnboardingAcceptTermsOfServiceScreen',
          builder: _i24.previewOnboardingAcceptTermsOfServiceScreen,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'OnboardingFinishedScreen',
        useCase: _i1.WidgetbookUseCase(
          name: 'OnboardingFinishedScreen',
          builder: _i25.previewOnboardingFinishedScreen,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'OnboardingSelectSigningCertificateScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'canceled',
            builder: _i26.previewCanceledOnboardingSelectSigningCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'initial',
            builder: _i26.previewInitialOnboardingSelectSigningCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'no certificate',
            builder:
                _i26.previewNoCertificateOnboardingSelectSigningCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i26.previewSuccessOnboardingSelectSigningCertificateBody,
          ),
        ],
      ),
      _i1.WidgetbookComponent(
        name: 'OpenDocumentScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i27.previewErrorOpenDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i27.previewLoadingOpenDocumentScreen,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'PairedDeviceListScreen',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i28.previewPairedDeviceListScreen,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'PresentSignedDocumentBody',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i29.previewErrorPresentSignedDocumentBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i29.previewLoadingPresentSignedDocumentBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i29.previewSuccessPresentSignedDocumentBody,
          ),
        ],
      ),
      _i1.WidgetbookComponent(
        name: 'PreviewDocumentScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i30.previewErrorPreviewDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i30.previewLoadingPreviewDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i30.previewSuccessPreviewDocumentScreen,
          ),
        ],
      ),
      _i1.WidgetbookComponent(
        name: 'SelectCertificateScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'canceled',
            builder: _i31.previewCanceledSelectCertificateScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i31.previewErrorSelectCertificateScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i31.previewLoadingSelectCertificateScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'no certificate',
            builder: _i31.previewNoCertificateSelectCertificateScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i31.previewSuccessSelectCertificateScreen,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'SettingsScreen',
        useCase: _i1.WidgetbookUseCase(
          name: 'SettingsScreen',
          builder: _i32.previewSettingsScreen,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'ShowTermsOfServiceScreen',
        useCase: _i1.WidgetbookUseCase(
          name: 'ShowTermsOfServiceScreen',
          builder: _i33.previewShowTermsOfServiceScreen,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'SignDocumentScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i34.previewErrorSignDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i34.previewLoadingSignDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i34.previewSuccessSignDocumentScreen,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'StartRemoteDocumentSigningScreen',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i35.previewStartRemoteDocumentSigningScreen,
        ),
      ),
    ],
  ),
];
