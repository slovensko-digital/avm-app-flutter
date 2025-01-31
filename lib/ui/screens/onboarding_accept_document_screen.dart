import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../di.dart';
import '../../strings_context.dart';
import '../../use_case/get_html_document_version_use_case.dart';
import '../../util/errors.dart';
import '../app_theme.dart';
import '../fragment/show_web_page_fragment.dart';
import '../onboarding.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/step_indicator.dart';
import 'show_document_screen.dart';

/// [Onboarding] screen to accept document - Privacy Policy or Terms of Service.
///
/// Uses [GetHtmlDocumentVersionUseCase].
///
/// See also:
///  - [ShowDocumentScreen]
class OnboardingAcceptDocumentScreen extends StatefulWidget {
  final String title;
  final Uri url;
  final int step;
  final AsyncValueSetter<String> versionSetter;
  final void Function(BuildContext context) onAccepted;

  const OnboardingAcceptDocumentScreen({
    super.key,
    required this.title,
    required this.url,
    required this.step,
    required this.versionSetter,
    required this.onAccepted,
  });

  @override
  State<OnboardingAcceptDocumentScreen> createState() =>
      _OnboardingAcceptDocumentScreenState();
}

class _OnboardingAcceptDocumentScreenState
    extends State<OnboardingAcceptDocumentScreen> {
  bool documentLoaded = false;
  bool documentVersionIsLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: _getBody(),
      ),
    );
  }

  Widget _getBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ShowWebPageFragment(
            url: widget.url,
            onUrlLoaded: () {
              if (mounted) {
                setState(() {
                  documentLoaded = true;
                });
              }
            },
          ),
        ),

        // Steps
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: StepIndicator(stepNumber: widget.step, totalSteps: 3),
        ),

        // Primary button
        Padding(
          padding: kScreenMargin,
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: kPrimaryButtonMinimumSize,
            ),
            onPressed:
                documentLoaded && !documentVersionIsLoading ? _onAccept : null,
            child: !documentLoaded || documentVersionIsLoading
                ? const LoadingIndicator()
                : Text(context.strings.buttonAgreeLabel),
          ),
        ),
      ],
    );
  }

  void _onAccept() async {
    final getDocumentVersion = getIt.get<GetHtmlDocumentVersionUseCase>();

    try {
      setState(() {
        documentVersionIsLoading = true;
      });

      final documentVersion = await getDocumentVersion(widget.url);

      await widget.versionSetter(documentVersion);

      if (mounted) {
        widget.onAccepted.call(context);
      }
    } catch (error) {
      _showError(error);

      setState(() {
        documentVersionIsLoading = false;
      });
    }
  }

  void _showError(Object error) {
    final snackBar = SnackBar(
      content: Text(getErrorMessage(error)),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: '',
  type: OnboardingAcceptDocumentScreen,
)
Widget previewOnboardingAcceptDocumentScreen(BuildContext context) {
  final strings = context.strings;
  final title = context.knobs.string(
    label: "Title",
    initialValue: strings.privacyPolicyTitle,
  );
  final url = context.knobs.string(
    label: "URL",
    initialValue: strings.privacyPolicyUrl,
  );

  return OnboardingAcceptDocumentScreen(
    title: title,
    url: Uri.parse(url),
    step: 1,
    versionSetter: (version) async {
      developer.log("$version accepted");
    },
    onAccepted: (_) {
      developer.log("onAccepted");
    },
  );
}
