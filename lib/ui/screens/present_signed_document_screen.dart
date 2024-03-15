import 'dart:io' show File;

import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/present_signed_document_cubit.dart';
import '../../file_extensions.dart';
import '../../util/errors.dart';
import '../app_theme.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';
import '../widgets/result_view.dart';

/// Screen for presenting signed document.
///
/// Uses [PresentSignedDocumentCubit].
class PresentSignedDocumentScreen extends StatelessWidget {
  final SignDocumentResponse signedDocument;

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
            return BlocBuilder<PresentSignedDocumentCubit,
                PresentSignedDocumentState>(
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

  /// Handles share file request.
  Future<void> _handleShareFile(BuildContext context) async {
    final cubit = context.read<PresentSignedDocumentCubit>();

    try {
      final file = await cubit.getAccessibleFile();

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: "Elektronicky podpísaný dokument",
        text: "\n\nPodpísané aplikáciou Autogram v Mobile",
      );
    } catch (error) {
      final snackBar = SnackBar(
        content: Text("Chyba: ${getErrorMessage(error)}"),
        action: SnackBarAction(
          label: "OK",
          onPressed: () {},
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
      // TODO UI for case, when unable to save file, however it can be still shared
      PresentSignedDocumentErrorState state => ErrorContent(
          title: "Pri ukladaní súboru sa vyskytla chyba",
          error: state.error,
        ),
      PresentSignedDocumentSuccessState state => _SuccessContent(
          file: state.file,
          onShareFileRequested: onShareFileRequested,
          onCloseRequested: onCloseRequested,
        ),
    };
  }
}

class _SuccessContent extends StatelessWidget {
  final File file;
  final VoidCallback? onShareFileRequested;
  final VoidCallback? onCloseRequested;

  const _SuccessContent({
    required this.file,
    required this.onShareFileRequested,
    required this.onCloseRequested,
  });

  @override
  Widget build(BuildContext context) {
    final fileNameTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.bold,
    );
    final body = RichText(
      text: TextSpan(
        text: "Dokument bol uložený do Downloads pod\u{00A0}názvom ",
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

    return Column(
      children: [
        Expanded(
          child: ResultView.success(
            titleText: "Dokument bol úspešne podpísaný",
            body: body,
          ),
        ),

        // Primary button
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: onShareFileRequested,
          child: const Text("Zdieľať podpísaný dokument"),
        ),

        const SizedBox(height: kButtonSpace),

        // Secondary button
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: onCloseRequested,
          child: const Text("Zavrieť"),
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
  return const PresentSignedDocumentBody(
    state: PresentSignedDocumentErrorState("Error!"),
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
