import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/material.dart';

import '../../bloc/select_signing_certificate_cubit.dart';
import '../../strings_context.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';
import '../widgets/retry_view.dart';

/// Fragment that is used in screens working with [SelectSigningCertificateState].
class SelectSigningCertificateFragment extends StatelessWidget {
  final SelectSigningCertificateState state;
  final VoidCallback? onReloadCertificatesRequested;
  final Widget Function(BuildContext context) initialBuilder;
  final Widget Function(BuildContext context, Certificate certificate)
      successBuilder;

  static Widget _defaultInitialBuilder(BuildContext context) =>
      const LoadingContent();

  const SelectSigningCertificateFragment({
    super.key,
    required this.state,
    required this.onReloadCertificatesRequested,
    this.initialBuilder = _defaultInitialBuilder,
    required this.successBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      SelectSigningCertificateInitialState _ => initialBuilder(context),
      SelectSigningCertificateLoadingState _ => const LoadingContent(),
      SelectSigningCertificateCanceledState _ => RetryView(
          headlineText: context.strings.selectSigningCertificateCanceledHeading,
          onRetryRequested: () {
            onReloadCertificatesRequested?.call();
          },
        ),
      SelectSigningCertificateNoCertificateState _ => RetryView(
          headlineText:
              context.strings.selectSigningCertificateNoCertificateHeading,
          onRetryRequested: () {
            onReloadCertificatesRequested?.call();
          },
        ),
      SelectSigningCertificateErrorState state => ErrorContent(
          title: context.strings.selectSigningCertificateErrorHeading,
          error: state.error,
        ),
      SelectSigningCertificateSuccessState state => successBuilder(
          context,
          state.certificate,
        ),
    };
  }
}
