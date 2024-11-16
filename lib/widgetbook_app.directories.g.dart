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
import 'package:autogram/ui/fragment/document_validation_info_fragment.dart'
    as _i25;
import 'package:autogram/ui/fragment/preview_document_fragment.dart' as _i26;
import 'package:autogram/ui/fragment/show_web_page_fragment.dart' as _i27;
import 'package:autogram/ui/screens/about_screen.dart' as _i30;
import 'package:autogram/ui/screens/main_menu_screen.dart' as _i31;
import 'package:autogram/ui/screens/main_screen.dart' as _i2;
import 'package:autogram/ui/screens/onboarding_accept_document_screen.dart'
    as _i32;
import 'package:autogram/ui/screens/onboarding_finished_screen.dart' as _i33;
import 'package:autogram/ui/screens/onboarding_select_signing_certificate_screen.dart'
    as _i34;
import 'package:autogram/ui/screens/open_document_screen.dart' as _i35;
import 'package:autogram/ui/screens/paired_device_list_screen.dart' as _i36;
import 'package:autogram/ui/screens/present_signed_document_screen.dart'
    as _i37;
import 'package:autogram/ui/screens/qr_code_scanner_screen.dart' as _i23;
import 'package:autogram/ui/screens/select_certificate_screen.dart' as _i38;
import 'package:autogram/ui/screens/settings_screen.dart' as _i39;
import 'package:autogram/ui/screens/show_document_screen.dart' as _i40;
import 'package:autogram/ui/screens/sign_document_screen.dart' as _i41;
import 'package:autogram/ui/screens/start_remote_document_signing_screen.dart'
    as _i42;
import 'package:autogram/ui/widgets/app_version_text.dart' as _i10;
import 'package:autogram/ui/widgets/autogram_logo.dart' as _i5;
import 'package:autogram/ui/widgets/buttons.dart' as _i6;
import 'package:autogram/ui/widgets/certificate_picker.dart' as _i28;
import 'package:autogram/ui/widgets/chip.dart' as _i7;
import 'package:autogram/ui/widgets/close_button.dart' as _i8;
import 'package:autogram/ui/widgets/dialogs.dart' as _i24;
import 'package:autogram/ui/widgets/document_validation_info.dart' as _i11;
import 'package:autogram/ui/widgets/document_validation_strip.dart' as _i12;
import 'package:autogram/ui/widgets/document_visualization.dart' as _i13;
import 'package:autogram/ui/widgets/error_content.dart' as _i14;
import 'package:autogram/ui/widgets/html_preview.dart' as _i15;
import 'package:autogram/ui/widgets/loading_content.dart' as _i16;
import 'package:autogram/ui/widgets/loading_indicator.dart' as _i9;
import 'package:autogram/ui/widgets/markdown_text.dart' as _i17;
import 'package:autogram/ui/widgets/option_picker.dart' as _i18;
import 'package:autogram/ui/widgets/preference_tile.dart' as _i19;
import 'package:autogram/ui/widgets/result_view.dart' as _i20;
import 'package:autogram/ui/widgets/retry_view.dart' as _i21;
import 'package:autogram/ui/widgets/signature_type_picker.dart' as _i29;
import 'package:autogram/ui/widgets/step_indicator.dart' as _i22;
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
            builder: _i6.previewFilledButton,
          ),
          _i1.WidgetbookUseCase(
            name: 'text',
            builder: _i6.previewTextButton,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'Chip',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i7.previewChip,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'CloseButton',
        useCase: _i1.WidgetbookUseCase(
          name: 'CloseButton',
          builder: _i8.previewCloseButton,
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
          builder: _i9.previewLoadingIndicator,
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
          builder: _i10.previewAppVersionText,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'DocumentValidationInfo',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i11.previewDocumentValidationInfo,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'DocumentValidationStrip',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i12.previewLoadingDocumentValidationStrip,
          ),
          _i1.WidgetbookUseCase(
            name: 'signatures',
            builder: _i12.previewOtherDocumentValidationStrip,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'DocumentVisualization',
        useCase: _i1.WidgetbookUseCase(
          name: 'DocumentVisualization',
          builder: _i13.previewDocumentVisualization,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'ErrorContent',
        useCase: _i1.WidgetbookUseCase(
          name: 'ErrorContent',
          builder: _i14.previewErrorContent,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'HtmlPreview',
        useCase: _i1.WidgetbookUseCase(
          name: 'HtmlPreview',
          builder: _i15.previewHtmlPreview,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'LoadingContent',
        useCase: _i1.WidgetbookUseCase(
          name: 'LoadingContent',
          builder: _i16.previewLoadingContent,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'MarkdownText',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i17.previewMarkdownText,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'OptionPicker',
        useCase: _i1.WidgetbookUseCase(
          name: 'OptionPicker',
          builder: _i18.previewOptionPicker,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'PreferenceTile',
        useCase: _i1.WidgetbookUseCase(
          name: 'PreferenceTile',
          builder: _i19.previewPreferenceTile,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'ResultView',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'custom',
            builder: _i20.previewCustomResultView,
          ),
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i20.previewErrorResultView,
          ),
          _i1.WidgetbookUseCase(
            name: 'info',
            builder: _i20.previewInfoResultView,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i20.previewSuccessResultView,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'RetryView',
        useCase: _i1.WidgetbookUseCase(
          name: 'RetryView',
          builder: _i21.previewRetryView,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'StepIndicator',
        useCase: _i1.WidgetbookUseCase(
          name: 'StepIndicator',
          builder: _i22.previewStepIndicator,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: '_ViewFinder',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i23.previewViewFinder,
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
          builder: _i24.previewNotificationsPermissionRationaleModal,
        ),
      )
    ],
  ),
  _i1.WidgetbookCategory(
    name: 'Fragments',
    children: [
      _i1.WidgetbookLeafComponent(
        name: 'DocumentValidationInfoFragment',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i25.previewDocumentValidationInfoFragment,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'PreviewDocumentFragment',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i26.previewErrorPreviewDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i26.previewLoadingPreviewDocumentFragment,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i26.previewSuccessPreviewDocumentScreen,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'ShowWebPageFragment',
        useCase: _i1.WidgetbookUseCase(
          name: 'ShowWebPageFragment',
          builder: _i27.previewShowWebPageFragment,
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
          name: 'CertificatePicker',
          builder: _i28.previewCertificatePicker,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'SignatureTypePicker',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i29.previewSignatureTypePicker,
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
          builder: _i30.previewAboutScreen,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'MainMenuScreen',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i31.previewMainMenuScreen,
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
        name: 'OnboardingAcceptDocumentScreen',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i32.previewOnboardingAcceptDocumentScreen,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'OnboardingFinishedScreen',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i33.previewOnboardingFinishedScreen,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'OnboardingSelectSigningCertificateScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'canceled',
            builder: _i34.previewCanceledOnboardingSelectSigningCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'initial',
            builder: _i34.previewInitialOnboardingSelectSigningCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'no certificate',
            builder:
                _i34.previewNoCertificateOnboardingSelectSigningCertificateBody,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i34.previewSuccessOnboardingSelectSigningCertificateBody,
          ),
        ],
      ),
      _i1.WidgetbookComponent(
        name: 'OpenDocumentScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i35.previewErrorOpenDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i35.previewLoadingOpenDocumentScreen,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'PairedDeviceListScreen',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i36.previewPairedDeviceListScreen,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'PresentSignedDocumentScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i37.previewErrorPresentSignedDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'initial',
            builder: _i37.previewInitialPresentSignedDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i37.previewLoadingPresentSignedDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i37.previewSuccessPresentSignedDocumentScreen,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'QRCodeScannerScreen',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i23.previewQRCodeScannerScreen,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'SelectCertificateScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'canceled',
            builder: _i38.previewCanceledSelectCertificateScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i38.previewErrorSelectCertificateScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i38.previewLoadingSelectCertificateScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'no certificate',
            builder: _i38.previewNoCertificateSelectCertificateScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i38.previewSuccessSelectCertificateScreen,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'SettingsScreen',
        useCase: _i1.WidgetbookUseCase(
          name: 'SettingsScreen',
          builder: _i39.previewSettingsScreen,
        ),
      ),
      _i1.WidgetbookLeafComponent(
        name: 'ShowDocumentScreen',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i40.previewShowDocumentScreen,
        ),
      ),
      _i1.WidgetbookComponent(
        name: 'SignDocumentScreen',
        useCases: [
          _i1.WidgetbookUseCase(
            name: 'error',
            builder: _i41.previewErrorSignDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'loading',
            builder: _i41.previewLoadingSignDocumentScreen,
          ),
          _i1.WidgetbookUseCase(
            name: 'success',
            builder: _i41.previewSuccessSignDocumentScreen,
          ),
        ],
      ),
      _i1.WidgetbookLeafComponent(
        name: 'StartRemoteDocumentSigningScreen',
        useCase: _i1.WidgetbookUseCase(
          name: '',
          builder: _i42.previewStartRemoteDocumentSigningScreen,
        ),
      ),
    ],
  ),
];
