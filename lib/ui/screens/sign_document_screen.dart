import 'package:autogram_sign/autogram_sign.dart'
    show SignDocumentResponseBody, SignDocumentResponseBodyMimeType;
import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/sign_document_cubit.dart';
import '../app_theme.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';
import '../widgets/retry_view.dart';
import 'present_signed_document_screen.dart';

/// Screen for signing the document by calling eID mSDK.
/// Uses [SignDocumentCubit].
///
/// Navigates next to [PresentSignedDocumentScreen] on success.
class SignDocumentScreen extends StatelessWidget {
  final String documentId;
  final Certificate certificate;
  final bool addTimeStamp;

  const SignDocumentScreen({
    super.key,
    required this.documentId,
    required this.certificate,
    required this.addTimeStamp,
  });

  @override
  Widget build(BuildContext context) {
    final body = BlocProvider<SignDocumentCubit>(
      create: (context) {
        return GetIt.instance.get<SignDocumentCubit>(
          param1: documentId,
          param2: certificate,
        )..signDocument(addTimeStamp);
      },
      child: BlocConsumer<SignDocumentCubit, SignDocumentState>(
        listener: (context, state) {
          if (state is SignDocumentSuccessState) {
            _onSuccess(context, state);
          }
        },
        builder: (context, state) {
          return _Body(
            state: state,
            onRetryRequested: () {
              context.read<SignDocumentCubit>().signDocument(addTimeStamp);
            },
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Podpisovanie dokumentu"),
      ),
      body: SafeArea(
        child: body,
      ),
    );
  }

  void _onSuccess(BuildContext context, SignDocumentSuccessState state) {
    final screen = PresentSignedDocumentScreen(
      signedDocument: state.signedDocument,
    );
    final route = MaterialPageRoute(
      builder: (context) => screen,
    );

    Navigator.of(context).pushAndRemoveUntil(
      route,
      (route) {
        // Remove until MainScreen
        return route.settings.name == '/';
      },
    );
  }
}

/// [SignDocumentScreen] body.
class _Body extends StatelessWidget {
  final SignDocumentState state;
  final VoidCallback? onRetryRequested;

  const _Body({required this.state, this.onRetryRequested});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kScreenMargin,
      child: _getChild(context, state),
    );
  }

  Widget _getChild(BuildContext context, SignDocumentState state) {
    return switch (state) {
      SignDocumentInitialState() => const LoadingContent(),
      SignDocumentLoadingState _ => const LoadingContent(),
      SignDocumentCanceledState _ => RetryView(
          headlineText:
              "Podpisovanie pomocou\u{00A0}OP\nbolo zrušené používateľom",
          onRetryRequested: onRetryRequested,
        ),
      SignDocumentErrorState state => ErrorContent(
          title: "Pri podpisovaní sa vyskytla chyba",
          error: state.error,
        ),
      SignDocumentSuccessState() => const LoadingContent(), // see listener
    };
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'loading',
  type: SignDocumentScreen,
)
Widget previewLoadingSignDocumentScreen(BuildContext context) {
  return const _Body(
    state: SignDocumentLoadingState(),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'error',
  type: SignDocumentScreen,
)
Widget previewErrorSignDocumentScreen(BuildContext context) {
  return const _Body(
    state: SignDocumentErrorState("Error message!"),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'success',
  type: SignDocumentScreen,
)
Widget previewSuccessSignDocumentScreen(BuildContext context) {
  return const _Body(
    state: SignDocumentSuccessState(
      SignDocumentResponseBody(
        filename: "document.pdf",
        mimeType: SignDocumentResponseBodyMimeType.applicationPdfBase64,
        content: "",
        issuedBy: "",
        signedBy: "",
      ),
    ),
  );
}
