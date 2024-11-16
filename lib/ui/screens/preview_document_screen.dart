import 'dart:io' show File;

import 'package:autogram_sign/autogram_sign.dart'
    show DocumentValidationResponseBody, DocumentVisualizationResponseBody;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/preview_document_cubit.dart';
import '../../data/document_signing_type.dart';
import '../../file_system_entity_extensions.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import '../fragment/document_validation_fragment.dart';
import '../fragment/document_validation_info_fragment.dart';
import '../widgets/document_visualization.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';
import 'open_document_screen.dart';
import 'select_certificate_screen.dart';

/// Screen for previewing single document from [file] and [documentId].
///
/// Uses [PreviewDocumentCubit].
/// TODO Also update docs - mention fragments
/// Navigates next to [SelectCertificateScreen].
/// Shows [DocumentValidationInfoFragment].
///
/// See also:
///  - [OpenDocumentScreen]
class PreviewDocumentScreen extends StatelessWidget {
  final File? file;
  final String documentId;

  const PreviewDocumentScreen({
    super.key,
    this.file,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    final body = BlocProvider<PreviewDocumentCubit>(
      create: (context) {
        return GetIt.instance.get<PreviewDocumentCubit>(
          param1: documentId,
        )..getVisualization();
      },
      child: BlocBuilder<PreviewDocumentCubit, PreviewDocumentState>(
        builder: (context, state) {
          return _Body(
            documentId: documentId,
            state: state,
            onSignRequested: () {
              _onSignRequested(context);
            },
            onShowDocumentValidationInfoRequested: (data) {
              _onShowDocumentValidationInfoRequested(context, data);
            },
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.previewDocumentTitle),
        actions: [
          if (file != null)
            IconButton(
              onPressed: () => _onShareRequested(context),
              icon: const Icon(Icons.share_outlined),
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
      body: SafeArea(
        child: body,
      ),
    );
  }

  Future<void> _onShareRequested(BuildContext context) async {
    final file = this.file;

    if (file != null) {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: file.basename,
        text: context.strings.shareDocumentText,
      );
    }
  }

  Future<void> _onSignRequested(BuildContext context) {
    final screen = SelectCertificateScreen(
      documentId: documentId,
      signingType:
          file != null ? DocumentSigningType.local : DocumentSigningType.remote,
    );
    final route = MaterialPageRoute(
      builder: (context) => screen,
    );

    return Navigator.of(context).push(route);
  }

  Future<void> _onShowDocumentValidationInfoRequested(
    BuildContext context,
    DocumentValidationResponseBody data,
  ) {
    // TODO Call avm.showModalBottomSheet
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return DocumentValidationInfoFragment(data: data);
      },
    );
  }
}

/// [PreviewDocumentScreen] body.
class _Body extends StatelessWidget {
  final String documentId;
  final PreviewDocumentState state;
  final VoidCallback? onSignRequested;
  final ValueSetter<DocumentValidationResponseBody>?
      onShowDocumentValidationInfoRequested;

  const _Body({
    this.documentId = '',
    required this.state,
    required this.onSignRequested,
    this.onShowDocumentValidationInfoRequested,
  });

  @override
  Widget build(BuildContext context) {
    final child1 = DocumentValidationFragment(
      documentId: documentId,
      onShowDocumentValidationInfoRequested: (data) {
        onShowDocumentValidationInfoRequested?.call(data);
      },
    );
    // TODO Extract whole child2 as Fragment, so it can have separate preview
    final child2 = switch (state) {
      PreviewDocumentInitialState _ => const LoadingContent(),
      PreviewDocumentLoadingState _ => const LoadingContent(),
      PreviewDocumentSuccessState state => _SuccessContent(
          visualization: state.visualization,
          onSignRequested: onSignRequested,
        ),
      PreviewDocumentErrorState state => ErrorContent(
          title: context.strings.previewDocumentErrorHeading,
          error: state.error,
        ),
    };
    final child = Column(
      children: [
        child1,
        Expanded(child: child2),
      ],
    );

    return child;
  }
}

/// Displays [visualization] inside [DocumentVisualization] with
/// primary button below.
class _SuccessContent extends StatelessWidget {
  final DocumentVisualizationResponseBody visualization;
  final VoidCallback? onSignRequested;

  const _SuccessContent({
    required this.visualization,
    required this.onSignRequested,
  });

  @override
  Widget build(BuildContext context) {
    final dashColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // Document preview
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: DottedBorder(
              color: dashColor,
              strokeWidth: 4,
              dashPattern: const [16, 16],
              padding: const EdgeInsets.all(0),
              child: DocumentVisualization(
                visualization: visualization,
              ),
            ),
          ),
        ),

        // Primary button
        Padding(
          padding: kScreenMargin,
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: kPrimaryButtonMinimumSize,
            ),
            onPressed: onSignRequested,
            child: Text(context.strings.buttonSignLabel),
          ),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'loading',
  type: PreviewDocumentScreen,
)
Widget previewLoadingPreviewDocumentScreen(BuildContext context) {
  return const _Body(
    state: PreviewDocumentLoadingState(),
    onSignRequested: null,
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'error',
  type: PreviewDocumentScreen,
)
Widget previewErrorPreviewDocumentScreen(BuildContext context) {
  return const _Body(
    state: PreviewDocumentErrorState("Error message!"),
    onSignRequested: null,
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'success',
  type: PreviewDocumentScreen,
)
Widget previewSuccessPreviewDocumentScreen(BuildContext context) {
  return const _Body(
    state: PreviewDocumentSuccessState(
      DocumentVisualizationResponseBody(
        mimeType: "text/plain;base64",
        filename: "sample.txt",
        content: "",
      ),
    ),
    onSignRequested: null,
  );
}
