import 'dart:io' show File, OSError, PathAccessException;

import 'package:autogram_sign/autogram_sign.dart' show SignDocumentResponseBody;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/present_signed_document_cubit.dart';
import '../../file_extensions.dart';
import '../../strings_context.dart';
import '../../util/errors.dart';
import '../app_theme.dart';
import '../widgets/loading_content.dart';
import '../widgets/result_view.dart';

/// Screen for presenting signed document.
///
/// Uses [PresentSignedDocumentCubit].
class PresentSignedDocumentScreen extends StatelessWidget {
  final SignDocumentResponseBody signedDocument;

  const PresentSignedDocumentScreen({
    super.key,
    required this.signedDocument,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PresentSignedDocumentCubit>(
      create: (context) {
        return GetIt.instance.get<PresentSignedDocumentCubit>(
          param1: signedDocument,
        )..saveDocument();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: Builder(
          builder: (context) {
            // Need outer Context to access Cubit
            return BlocConsumer<PresentSignedDocumentCubit,
                PresentSignedDocumentState>(
              listener: (context, state) {
                if (state is PresentSignedDocumentErrorState) {
                  final error = state.error;
                  final message = context.strings
                      .saveSignedDocumentErrorMessage(getErrorMessage(error));

                  _showError(context, message);
                }
              },
              builder: (context, state) {
                return PresentSignedDocumentBody(
                  state: state,
                  onShareFileRequested: () => _handleShareFile(context),
                  onCloseRequested: () => _handleClose(context),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 10),
      content: Text(message),
      action: SnackBarAction(
        onPressed: () {
          // Hides automatically
        },
        label: context.strings.buttonOKLabel,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Handles share file request.
  Future<void> _handleShareFile(BuildContext context) async {
    final cubit = context.read<PresentSignedDocumentCubit>();
    final strings = context.strings;

    try {
      final file = await cubit.getShareableFile();

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: strings.shareSignedDocumentSubject,
        text: strings.shareSignedDocumentText,
      );
    } catch (error) {
      if (context.mounted) {
        final message =
            strings.shareSignedDocumentErrorMessage(getErrorMessage(error));
        _showError(context, message);
      }
    }
  }

  /// Handles close request.
  Future<void> _handleClose(BuildContext context) {
    return Navigator.of(context).maybePop();
  }
}

/// [PresentSignedDocumentScreen] body.
class PresentSignedDocumentBody extends StatelessWidget {
  final PresentSignedDocumentState state;
  final VoidCallback? onShareFileRequested;
  final VoidCallback? onCloseRequested;

  const PresentSignedDocumentBody({
    super.key,
    required this.state,
    this.onShareFileRequested,
    this.onCloseRequested,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kScreenMargin,
      child: _getChild(context),
    );
  }

  Widget _getChild(BuildContext context) {
    return switch (state) {
      PresentSignedDocumentInitialState _ => const LoadingContent(),
      PresentSignedDocumentLoadingState _ => const LoadingContent(),
      PresentSignedDocumentErrorState _ => _SuccessContent(
          file: null,
          onShareFileRequested: onShareFileRequested,
          onCloseRequested: onCloseRequested,
        ),
      PresentSignedDocumentSuccessState state => _SuccessContent(
          file: state.file,
          onShareFileRequested: onShareFileRequested,
          onCloseRequested: onCloseRequested,
        ),
    };
  }
}

/// This presents main content when [File] also cannot be saved for some reason.
/// However, still can request to share it and navigate.
class _SuccessContent extends StatelessWidget {
  final File? file;
  final VoidCallback? onShareFileRequested;
  final VoidCallback? onCloseRequested;

  const _SuccessContent({
    required this.file,
    required this.onShareFileRequested,
    required this.onCloseRequested,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final file = this.file;
    Widget body = const SizedBox(height: 58);

    if (file != null) {
      final fileNameTextStyle = TextStyle(
        color: Theme.of(context).colorScheme.primary,
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.bold,
      );
      body = RichText(
        text: TextSpan(
          text: strings.saveSignedDocumentSuccessMessage,
          style: Theme.of(context).textTheme.bodyLarge,
          //style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          children: [
            // Emphasize file name
            TextSpan(
              text: file.basename,
              style: fileNameTextStyle,
              recognizer: TapGestureRecognizer()..onTap = onShareFileRequested,
            )
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    return Column(
      children: [
        Expanded(
          child: ResultView.success(
            titleText: strings.documentSigningSuccessTitle,
            body: body,
          ),
        ),

        // Primary button
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: onShareFileRequested,
          child: Text(strings.shareSignedDocumentLabel),
        ),

        const SizedBox(height: kButtonSpace),

        // Secondary button
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: onCloseRequested,
          child: Text(strings.buttonCancelLabel),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'loading',
  type: PresentSignedDocumentBody,
)
Widget previewLoadingPresentSignedDocumentBody(BuildContext context) {
  return const PresentSignedDocumentBody(
    state: PresentSignedDocumentLoadingState(),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'error',
  type: PresentSignedDocumentBody,
)
Widget previewErrorPresentSignedDocumentBody(BuildContext context) {
  // TODO Should preview whole Screen class also with BlocConsumer.listener
  const error = PathAccessException(
    "/storage/emulated/0/Download/container-signed-xades-baseline-b.sce",
    OSError("Permission denied", 13),
    "Cannot open file",
  );

  return PresentSignedDocumentBody(
    state: const PresentSignedDocumentErrorState(error),
    onShareFileRequested: () {},
    onCloseRequested: () {},
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'success',
  type: PresentSignedDocumentBody,
)
Widget previewSuccessPresentSignedDocumentBody(BuildContext context) {
  final fileName = context.knobs.string(
    label: "File name",
    initialValue: "document_signed.pdf",
  );
  final file = File(fileName);

  return PresentSignedDocumentBody(
    state: PresentSignedDocumentSuccessState(file),
    onShareFileRequested: () {},
    onCloseRequested: () {},
  );
}
