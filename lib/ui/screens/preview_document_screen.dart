import 'dart:developer' as developer;
import 'dart:io' show File;

import 'package:autogram_sign/autogram_sign.dart'
    show DocumentValidationResponseBody, DocumentVisualizationResponseBody;
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
import '../fragment/preview_document_fragment.dart';
import '../widgets/dialogs.dart' as avm;
import 'open_document_screen.dart';
import 'select_certificate_screen.dart';

/// Screen for previewing single document from [file] and [documentId].
///
/// Contains two fragments:
///  - [DocumentValidationFragment]
///  - [PreviewDocumentFragment]
///
/// Uses [PreviewDocumentCubit].
///
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
    final child1 = DocumentValidationFragment(
      documentId: documentId,
      onShowDocumentValidationInfoRequested: (data) {
        _onShowDocumentValidationInfoRequested(context, data);
      },
    );
    final child2 = BlocProvider<PreviewDocumentCubit>(
      create: (context) {
        return GetIt.instance.get<PreviewDocumentCubit>(
          param1: documentId,
        )..getVisualization();
      },
      child: BlocBuilder<PreviewDocumentCubit, PreviewDocumentState>(
        builder: (context, state) {
          return _Body(
            state: state,
            onSignRequested: () => _onSignRequested(context),
          );
        },
      ),
    );

    final body = Column(
      children: [
        child1,
        Expanded(child: child2),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.previewDocumentTitle),
        actions: [
          if (file != null)
            Semantics(
              label: context.strings.shareDocumentPreviewSemantics,
              excludeSemantics: true,
              button: true,
              child: IconButton(
                onPressed: () => _onShareRequested(context),
                icon: const Icon(Icons.share_outlined),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: body,
      ),
    );
  }

  Future<void> _onShowDocumentValidationInfoRequested(
    BuildContext context,
    DocumentValidationResponseBody data,
  ) {
    return avm.showModalBottomSheet(
      context: context,
      child: SizedBox(
        height: 240,
        child: DocumentValidationInfoFragment(data: data),
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
}

/// [PreviewDocumentScreen] body.
class _Body extends StatelessWidget {
  final PreviewDocumentState state;
  final VoidCallback? onSignRequested;

  const _Body({
    required this.state,
    this.onSignRequested,
  });

  @override
  Widget build(BuildContext context) {
    if (state is PreviewDocumentSuccessState) {
      // Top content has no Padding intentionally!
      return Column(
        children: [
          // Document preview
          Expanded(
            child: PreviewDocumentFragment(state: state),
          ),

          // Primary button
          Padding(
            padding: kScreenMargin,
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: kPrimaryButtonMinimumSize,
              ),
              onPressed: () => onSignRequested?.call(),
              child: Text(context.strings.buttonSignLabel),
            ),
          ),
        ],
      );
    } else {
      return Padding(
        padding: kScreenMargin,
        child: PreviewDocumentFragment(state: state),
      );
    }
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
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'success',
  type: PreviewDocumentScreen,
)
Widget previewSuccessPreviewDocumentScreen(BuildContext context) {
  return _Body(
    state: const PreviewDocumentSuccessState(
      DocumentVisualizationResponseBody(
        mimeType: "text/plain",
        filename: "sample.txt",
        content: "Sample text",
      ),
    ),
    onSignRequested: () {
      developer.log("onSignRequested");
    },
  );
}
