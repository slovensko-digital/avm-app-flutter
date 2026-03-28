// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:autogram/ui/app_theme.dart' as _autogram_ui_app_theme;
import 'package:autogram/ui/assets.dart' as _autogram_ui_assets;
import 'package:autogram/ui/fragment/document_validation_info_fragment.dart'
    as _autogram_ui_fragment_document_validation_info_fragment;
import 'package:autogram/ui/fragment/preview_document_fragment.dart'
    as _autogram_ui_fragment_preview_document_fragment;
import 'package:autogram/ui/fragment/show_web_page_fragment.dart'
    as _autogram_ui_fragment_show_web_page_fragment;
import 'package:autogram/ui/screens/about_screen.dart'
    as _autogram_ui_screens_about_screen;
import 'package:autogram/ui/screens/main_menu_screen.dart'
    as _autogram_ui_screens_main_menu_screen;
import 'package:autogram/ui/screens/main_screen.dart'
    as _autogram_ui_screens_main_screen;
import 'package:autogram/ui/screens/onboarding_accept_document_screen.dart'
    as _autogram_ui_screens_onboarding_accept_document_screen;
import 'package:autogram/ui/screens/onboarding_finished_screen.dart'
    as _autogram_ui_screens_onboarding_finished_screen;
import 'package:autogram/ui/screens/onboarding_select_signing_certificate_screen.dart'
    as _autogram_ui_screens_onboarding_select_signing_certificate_screen;
import 'package:autogram/ui/screens/open_document_screen.dart'
    as _autogram_ui_screens_open_document_screen;
import 'package:autogram/ui/screens/paired_device_list_screen.dart'
    as _autogram_ui_screens_paired_device_list_screen;
import 'package:autogram/ui/screens/present_signed_document_screen.dart'
    as _autogram_ui_screens_present_signed_document_screen;
import 'package:autogram/ui/screens/qr_code_scanner_screen.dart'
    as _autogram_ui_screens_qr_code_scanner_screen;
import 'package:autogram/ui/screens/select_certificate_screen.dart'
    as _autogram_ui_screens_select_certificate_screen;
import 'package:autogram/ui/screens/settings_screen.dart'
    as _autogram_ui_screens_settings_screen;
import 'package:autogram/ui/screens/show_document_screen.dart'
    as _autogram_ui_screens_show_document_screen;
import 'package:autogram/ui/screens/sign_document_screen.dart'
    as _autogram_ui_screens_sign_document_screen;
import 'package:autogram/ui/screens/start_remote_document_signing_screen.dart'
    as _autogram_ui_screens_start_remote_document_signing_screen;
import 'package:autogram/ui/widgets/app_version_text.dart'
    as _autogram_ui_widgets_app_version_text;
import 'package:autogram/ui/widgets/autogram_logo.dart'
    as _autogram_ui_widgets_autogram_logo;
import 'package:autogram/ui/widgets/buttons.dart'
    as _autogram_ui_widgets_buttons;
import 'package:autogram/ui/widgets/certificate_details.dart'
    as _autogram_ui_widgets_certificate_details;
import 'package:autogram/ui/widgets/certificate_picker.dart'
    as _autogram_ui_widgets_certificate_picker;
import 'package:autogram/ui/widgets/chip.dart' as _autogram_ui_widgets_chip;
import 'package:autogram/ui/widgets/close_button.dart'
    as _autogram_ui_widgets_close_button;
import 'package:autogram/ui/widgets/dialogs.dart'
    as _autogram_ui_widgets_dialogs;
import 'package:autogram/ui/widgets/document_signature_info.dart'
    as _autogram_ui_widgets_document_signature_info;
import 'package:autogram/ui/widgets/document_validation_strip.dart'
    as _autogram_ui_widgets_document_validation_strip;
import 'package:autogram/ui/widgets/document_visualization.dart'
    as _autogram_ui_widgets_document_visualization;
import 'package:autogram/ui/widgets/error_content.dart'
    as _autogram_ui_widgets_error_content;
import 'package:autogram/ui/widgets/html_preview.dart'
    as _autogram_ui_widgets_html_preview;
import 'package:autogram/ui/widgets/loading_content.dart'
    as _autogram_ui_widgets_loading_content;
import 'package:autogram/ui/widgets/loading_indicator.dart'
    as _autogram_ui_widgets_loading_indicator;
import 'package:autogram/ui/widgets/markdown_text.dart'
    as _autogram_ui_widgets_markdown_text;
import 'package:autogram/ui/widgets/option_picker.dart'
    as _autogram_ui_widgets_option_picker;
import 'package:autogram/ui/widgets/preference_tile.dart'
    as _autogram_ui_widgets_preference_tile;
import 'package:autogram/ui/widgets/result_view.dart'
    as _autogram_ui_widgets_result_view;
import 'package:autogram/ui/widgets/retry_view.dart'
    as _autogram_ui_widgets_retry_view;
import 'package:autogram/ui/widgets/signature_type_picker.dart'
    as _autogram_ui_widgets_signature_type_picker;
import 'package:autogram/ui/widgets/step_indicator.dart'
    as _autogram_ui_widgets_step_indicator;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookCategory(
    name: 'AVM',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'AppBar',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'main',
            builder: _autogram_ui_screens_main_screen.previewMainAppBar,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'normal',
            builder: _autogram_ui_app_theme.previewAppBar,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'Asset',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'icons',
            builder: _autogram_ui_assets.previewIcons,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'images',
            builder: _autogram_ui_assets.previewImages,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'AutogramLogo',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'AutogramLogo',
            builder: _autogram_ui_widgets_autogram_logo.previewAutogramLogo,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'Button',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'elevated',
            builder: _autogram_ui_widgets_buttons.previewElevatedButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'filled',
            builder: _autogram_ui_widgets_buttons.previewFilledButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'square',
            builder: _autogram_ui_widgets_buttons.previewSquareButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'text',
            builder: _autogram_ui_widgets_buttons.previewTextButton,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'Chip',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder: _autogram_ui_widgets_chip.previewChip,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'CloseButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'CloseButton',
            builder: _autogram_ui_widgets_close_button.previewCloseButton,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'Dialog',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Dialog',
            builder: _autogram_ui_app_theme.previewDialog,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'LoadingIndicator',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'LoadingIndicator',
            builder:
                _autogram_ui_widgets_loading_indicator.previewLoadingIndicator,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'MaterialBanner',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'MaterialBanner ',
            builder: _autogram_ui_app_theme.previewMaterialBanner,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'Radio',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Radio',
            builder: _autogram_ui_app_theme.previewRadio,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SnackBar',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'SnackBar',
            builder: _autogram_ui_app_theme.previewSnackBar,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Core',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'AppVersionText',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder:
                _autogram_ui_widgets_app_version_text.previewAppVersionText,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'CertificateDetails',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'CertificateDetails',
            builder: _autogram_ui_widgets_certificate_details
                .previewCertificateDetails,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'DocumentSignatureInfo',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder: _autogram_ui_widgets_document_signature_info
                .previewDocumentSignatureInfo,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'DocumentValidationStrip',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'loading',
            builder: _autogram_ui_widgets_document_validation_strip
                .previewLoadingDocumentValidationStrip,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'signatures',
            builder: _autogram_ui_widgets_document_validation_strip
                .previewOtherDocumentValidationStrip,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'DocumentVisualization',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'DocumentVisualization',
            builder: _autogram_ui_widgets_document_visualization
                .previewDocumentVisualization,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ErrorContent',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'ErrorContent',
            builder: _autogram_ui_widgets_error_content.previewErrorContent,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'HtmlPreview',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'HtmlPreview',
            builder: _autogram_ui_widgets_html_preview.previewHtmlPreview,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'LoadingContent',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'LoadingContent',
            builder: _autogram_ui_widgets_loading_content.previewLoadingContent,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'MarkdownText',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder: _autogram_ui_widgets_markdown_text.previewMarkdownText,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'OptionPicker',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'OptionPicker',
            builder: _autogram_ui_widgets_option_picker.previewOptionPicker,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'PreferenceTile',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'PreferenceTile',
            builder: _autogram_ui_widgets_preference_tile.previewPreferenceTile,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ResultView',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'custom',
            builder: _autogram_ui_widgets_result_view.previewCustomResultView,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'error',
            builder: _autogram_ui_widgets_result_view.previewErrorResultView,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'info',
            builder: _autogram_ui_widgets_result_view.previewInfoResultView,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'success',
            builder: _autogram_ui_widgets_result_view.previewSuccessResultView,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'RetryView',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'RetryView',
            builder: _autogram_ui_widgets_retry_view.previewRetryView,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StepIndicator',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'StepIndicator',
            builder: _autogram_ui_widgets_step_indicator.previewStepIndicator,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: '_InfoPanel',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder:
                _autogram_ui_screens_qr_code_scanner_screen.previewInfoPanel,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: '_ViewFinder',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder:
                _autogram_ui_screens_qr_code_scanner_screen.previewViewFinder,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Dialogs',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'BottomSheet',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'NotificationsPermissionRationale',
            builder: _autogram_ui_widgets_dialogs
                .previewNotificationsPermissionRationaleModal,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Fragments',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'DocumentValidationInfoFragment',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder: _autogram_ui_fragment_document_validation_info_fragment
                .previewDocumentValidationInfoFragment,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'PreviewDocumentFragment',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'error',
            builder: _autogram_ui_fragment_preview_document_fragment
                .previewErrorPreviewDocumentScreen,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'loading',
            builder: _autogram_ui_fragment_preview_document_fragment
                .previewLoadingPreviewDocumentFragment,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'success',
            builder: _autogram_ui_fragment_preview_document_fragment
                .previewSuccessPreviewDocumentScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ShowWebPageFragment',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'ShowWebPageFragment',
            builder: _autogram_ui_fragment_show_web_page_fragment
                .previewShowWebPageFragment,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Lists',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'CertificatePicker',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'CertificatePicker',
            builder: _autogram_ui_widgets_certificate_picker
                .previewCertificatePicker,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SignatureTypePicker',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder: _autogram_ui_widgets_signature_type_picker
                .previewSignatureTypePicker,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Screens',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'AboutScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'AboutScreen',
            builder: _autogram_ui_screens_about_screen.previewAboutScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'MainMenuScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder:
                _autogram_ui_screens_main_menu_screen.previewMainMenuScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'MainScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder: _autogram_ui_screens_main_screen.previewMainScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'OnboardingAcceptDocumentScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder: _autogram_ui_screens_onboarding_accept_document_screen
                .previewOnboardingAcceptDocumentScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'OnboardingFinishedScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder: _autogram_ui_screens_onboarding_finished_screen
                .previewOnboardingFinishedScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'OnboardingSelectSigningCertificateScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'canceled',
            builder:
                _autogram_ui_screens_onboarding_select_signing_certificate_screen
                    .previewCanceledOnboardingSelectSigningCertificateBody,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'initial',
            builder:
                _autogram_ui_screens_onboarding_select_signing_certificate_screen
                    .previewInitialOnboardingSelectSigningCertificateBody,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'no certificate',
            builder:
                _autogram_ui_screens_onboarding_select_signing_certificate_screen
                    .previewNoCertificateOnboardingSelectSigningCertificateBody,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'success',
            builder:
                _autogram_ui_screens_onboarding_select_signing_certificate_screen
                    .previewSuccessOnboardingSelectSigningCertificateBody,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'OpenDocumentScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'error',
            builder: _autogram_ui_screens_open_document_screen
                .previewErrorOpenDocumentScreen,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'loading',
            builder: _autogram_ui_screens_open_document_screen
                .previewLoadingOpenDocumentScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'PairedDeviceListScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder: _autogram_ui_screens_paired_device_list_screen
                .previewPairedDeviceListScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'PresentSignedDocumentScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'error',
            builder: _autogram_ui_screens_present_signed_document_screen
                .previewErrorPresentSignedDocumentScreen,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'initial',
            builder: _autogram_ui_screens_present_signed_document_screen
                .previewInitialPresentSignedDocumentScreen,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'loading',
            builder: _autogram_ui_screens_present_signed_document_screen
                .previewLoadingPresentSignedDocumentScreen,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'success',
            builder: _autogram_ui_screens_present_signed_document_screen
                .previewSuccessPresentSignedDocumentScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'QRCodeScannerScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder: _autogram_ui_screens_qr_code_scanner_screen
                .previewQRCodeScannerScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SelectCertificateScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'canceled',
            builder: _autogram_ui_screens_select_certificate_screen
                .previewCanceledSelectCertificateScreen,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'error',
            builder: _autogram_ui_screens_select_certificate_screen
                .previewErrorSelectCertificateScreen,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'loading',
            builder: _autogram_ui_screens_select_certificate_screen
                .previewLoadingSelectCertificateScreen,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'no certificate',
            builder: _autogram_ui_screens_select_certificate_screen
                .previewNoCertificateSelectCertificateScreen,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'success',
            builder: _autogram_ui_screens_select_certificate_screen
                .previewSuccessSelectCertificateScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SettingsScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'SettingsScreen',
            builder: _autogram_ui_screens_settings_screen.previewSettingsScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ShowDocumentScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder: _autogram_ui_screens_show_document_screen
                .previewShowDocumentScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SignDocumentScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'error',
            builder: _autogram_ui_screens_sign_document_screen
                .previewErrorSignDocumentScreen,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'loading',
            builder: _autogram_ui_screens_sign_document_screen
                .previewLoadingSignDocumentScreen,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'success',
            builder: _autogram_ui_screens_sign_document_screen
                .previewSuccessSignDocumentScreen,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StartRemoteDocumentSigningScreen',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '',
            builder: _autogram_ui_screens_start_remote_document_signing_screen
                .previewStartRemoteDocumentSigningScreen,
          ),
        ],
      ),
    ],
  ),
];
