import 'dart:developer' as developer;
import 'dart:io' show File, OSError, PathAccessException;

import 'package:autogram_sign/autogram_sign.dart' show SignDocumentResponseBody;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/present_signed_document_cubit.dart';
import '../../data/document_signing_type.dart';
import '../../di.dart';
import '../../directory_extensions.dart';
import '../../file_extensions.dart';
import '../../strings_context.dart';
import '../../util/errors.dart';
import '../app_theme.dart';
import '../widgets/loading_content.dart';
import '../widgets/markdown_text.dart';
import '../widgets/result_view.dart';

/// Screen for presenting signed document.
///
/// When [signingType] is [DocumentSigningType.local], then document is saved
/// into this device and also "Share" button is visible.
///
/// Uses [PresentSignedDocumentCubit].
class PresentSignedDocumentScreen extends StatelessWidget {
  final SignDocumentResponseBody signedDocument;
  final DocumentSigningType signingType;

  const PresentSignedDocumentScreen({
    super.key,
    required this.signedDocument,
    required this.signingType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PresentSignedDocumentCubit>(
      create: (context) {
        final cubit = getIt.get<PresentSignedDocumentCubit>(
          param1: signedDocument,
        );

        if (signingType == DocumentSigningType.local) {
          cubit.saveDocument();
        }

        return cubit;
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
                return _Body(
                  state: state,
                  signingType: signingType,
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
class _Body extends StatelessWidget {
  final PresentSignedDocumentState state;
  final DocumentSigningType signingType;
  final VoidCallback? onShareFileRequested;
  final VoidCallback? onCloseRequested;

  const _Body({
    required this.state,
    required this.signingType,
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
    final sharingEnabled = (signingType == DocumentSigningType.local);
    final onShareFileRequested =
        sharingEnabled ? this.onShareFileRequested : null;

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
      final directory = _getParentDirectoryName(file);
      final name = file.basename;
      final text = strings.saveSignedDocumentSuccessMessage(directory, name);

      body = MarkdownText(
        text,
        onLinkTap: (_, __, ___) {
          onShareFileRequested?.call();
        },
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

        if (onShareFileRequested != null)
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
          child: Text(strings.buttonCloseLabel),
        ),
      ],
    );
  }

  static String _getParentDirectoryName(File file) {
    return kIsWeb
        ? file.uri
                .resolve('.')
                .path
                .split('/')
                .where((e) => e.isNotEmpty)
                .lastOrNull ??
            '&nbsp;'
        // TODO Also check UI on iOS
        : file.parent.basename;
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'initial',
  type: PresentSignedDocumentScreen,
)
Widget previewInitialPresentSignedDocumentScreen(BuildContext context) {
  final signingType = context.knobs.list(
    label: "Signing type",
    options: DocumentSigningType.values,
    initialOption: DocumentSigningType.local,
  );

  return _Body(
    state: const PresentSignedDocumentInitialState(),
    signingType: signingType,
    onShareFileRequested: () {
      developer.log('onShareFileRequested');
    },
    onCloseRequested: () {
      developer.log('onCloseRequested');
    },
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'loading',
  type: PresentSignedDocumentScreen,
)
Widget previewLoadingPresentSignedDocumentScreen(BuildContext context) {
  final signingType = context.knobs.list(
    label: "Signing type",
    options: DocumentSigningType.values,
    initialOption: DocumentSigningType.local,
  );

  return _Body(
    state: const PresentSignedDocumentLoadingState(),
    signingType: signingType,
    onShareFileRequested: () {
      developer.log('onShareFileRequested');
    },
    onCloseRequested: () {
      developer.log('onCloseRequested');
    },
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'error',
  type: PresentSignedDocumentScreen,
)
Widget previewErrorPresentSignedDocumentScreen(BuildContext context) {
  final signingType = context.knobs.list(
    label: "Signing type",
    options: DocumentSigningType.values,
    initialOption: DocumentSigningType.local,
  );

  // TODO Should preview whole Screen class also with BlocConsumer.listener to display error in SnackBar
  const error = PathAccessException(
    "/storage/emulated/0/Download/container-signed-xades-baseline-b.sce",
    OSError("Permission denied", 13),
    "Cannot open file",
  );

  return _Body(
    state: const PresentSignedDocumentErrorState(error),
    signingType: signingType,
    onShareFileRequested: () {
      developer.log('onShareFileRequested');
    },
    onCloseRequested: () {
      developer.log('onCloseRequested');
    },
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'success',
  type: PresentSignedDocumentScreen,
)
Widget previewSuccessPresentSignedDocumentScreen(BuildContext context) {
  final signingType = context.knobs.list(
    label: "Signing type",
    options: DocumentSigningType.values,
    initialOption: DocumentSigningType.local,
  );
  final path = context.knobs.string(
    label: "File path",
    initialValue: "Downloads/document_signed.pdf",
  );
  final file = File(path);

  return _Body(
    state: PresentSignedDocumentSuccessState(file),
    signingType: signingType,
    onShareFileRequested: () {
      developer.log('onShareFileRequested');
    },
    onCloseRequested: () {
      developer.log('onCloseRequested');
    },
  );
}
