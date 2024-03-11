import 'dart:io' show File;

import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/present_signed_document_cubit.dart';
import '../../file_extensions.dart';
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
          actions: [
            IconButton(
              onPressed: () {
                Navigator.maybeOf(context)?.pop(signedDocument);
              },
              icon: const Icon(Icons.close_outlined),
            )
          ],
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
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleShareFile(BuildContext context) async {
    final cubit = context.read<PresentSignedDocumentCubit>();

    // TODO Handle case when file was manually deleted
    final file = await cubit.getAccessibleFile();

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: "Elektronicky podpísaný dokument",
      text: "\n\nPodpísané aplikáciou Autogram v Mobile",
    );
  }
}

/// [PresentSignedDocumentScreen] body.
class PresentSignedDocumentBody extends StatelessWidget {
  final PresentSignedDocumentState state;
  final VoidCallback? onShareFileRequested;

  const PresentSignedDocumentBody({
    super.key,
    required this.state,
    this.onShareFileRequested,
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
      PresentSignedDocumentLoadingState _ => const LoadingContent(),
      PresentSignedDocumentErrorState state => ErrorContent(
          title: "Pri ukladaní súboru sa vyskytla chyba",
          error: state.error,
        ),
      PresentSignedDocumentSuccessState state => _SuccessContent(
          file: state.file,
          onShareFileRequested: onShareFileRequested,
        ),
      _ => Text("### $state ###"),
    };
  }
}

class _SuccessContent extends StatelessWidget {
  final File file;
  final VoidCallback? onShareFileRequested;

  const _SuccessContent({
    required this.file,
    required this.onShareFileRequested,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ResultView.success(
            headlineText: "Dokument bol úspešne podpísaný",
            body: RichText(
              text: TextSpan(
                text: "Dokument bol uložený pod\u{00A0}názvom\n",
                style: Theme.of(context).textTheme.bodyLarge,
                //style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                children: [
                  // Emphasize file name
                  TextSpan(
                    text: file.basename,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                    recognizer: TapGestureRecognizer()
                      ..onTap = onShareFileRequested,
                  )
                ],
              ),
              textAlign: TextAlign.center,
            ),
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
  final file = File("document_signed.pdf");

  return PresentSignedDocumentBody(
    state: PresentSignedDocumentSuccessState(file),
  );
}
