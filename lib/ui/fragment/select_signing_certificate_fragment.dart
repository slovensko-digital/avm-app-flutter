import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/material.dart';

import '../../bloc/select_signing_certificate_cubit.dart';
import '../../strings_context.dart';
import '../screens/id_card_troubleshooting_dialog.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';
import '../widgets/markdown_text.dart';
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
          actionButtonLabel: strings.troubleshootingButtonLabel,
          onActionPressed: () => showTroubleshootingDialog(context),
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

    return ResultView(
      icon: 'assets/images/lock.svg',
      titleText: strings.selectSigningCertificateNoCertificateHeading,
      body: MarkdownText(
        strings.selectSigningCertificateNoCertificateBody,
      ),
    );
  }

  /// Shows the troubleshooting dialog with ID card attachment instructions.
  static void showTroubleshootingDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) => const IdCardTroubleshootingDialog(),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
