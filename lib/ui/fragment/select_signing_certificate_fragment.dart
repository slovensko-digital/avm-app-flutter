import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;

import '../../bloc/select_signing_certificate_cubit.dart';
import '../../strings_context.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';
import '../widgets/result_view.dart';

/// Fragment that is used in screens working with [SelectSigningCertificateState].
class SelectSigningCertificateFragment extends StatelessWidget {
  final SelectSigningCertificateState state;
  final Widget Function(BuildContext context) initialBuilder;
  final Widget Function(BuildContext context, Certificate certificate)
      successBuilder;

  static Widget _defaultInitialBuilder(BuildContext context) =>
      const LoadingContent();

  const SelectSigningCertificateFragment({
    super.key,
    required this.state,
    this.initialBuilder = _defaultInitialBuilder,
    required this.successBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return switch (state) {
      SelectSigningCertificateInitialState _ => initialBuilder(context),
      SelectSigningCertificateLoadingState _ => const LoadingContent(),
      SelectSigningCertificateCanceledState _ => canceledContent(context),
      SelectSigningCertificateNoCertificateState _ =>
        noCertificatesContent(context),
      SelectSigningCertificateErrorState state => ErrorContent(
          title: strings.selectSigningCertificateErrorHeading,
          error: state.error,
        ),
      SelectSigningCertificateSuccessState state => successBuilder(
          context,
          state.certificate,
        ),
    };
  }

  /// Partial content for "canceled" state.
  static Widget canceledContent(BuildContext context) {
    final strings = context.strings;

    return ResultView(
      icon: 'assets/images/close.svg',
      titleText: strings.selectSigningCertificateCanceledHeading,
      body: Text(strings.selectSigningCertificateCanceledBody),
    );
  }

  /// Partial content for "no certificates" state.
  static Widget noCertificatesContent(BuildContext context) {
    final strings = context.strings;
    final address =
        Uri.parse(strings.selectSigningCertificateNoCertificateGuideUrl);

    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final body = RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: strings.selectSigningCertificateNoCertificateBody,
            style: textStyle,
          ),
          TextSpan(
            text: address.authority,
            style: textStyle?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(address);
              },
          ),
          TextSpan(
            text: ".",
            style: textStyle,
          ),
        ],
      ),
    );

    return ResultView(
      icon: 'assets/images/lock.svg',
      titleText: strings.selectSigningCertificateNoCertificateHeading,
      body: body,
    );
  }
}
