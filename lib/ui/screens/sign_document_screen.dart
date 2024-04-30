import 'package:autogram_sign/autogram_sign.dart'
    show SignDocumentResponseBody, SignDocumentResponseBodyMimeType;
import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/sign_document_cubit.dart';
import '../../data/document_signing_type.dart';
import '../../data/signature_type.dart';
import '../../strings_context.dart';
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
  final SignatureType signatureType;
  final DocumentSigningType signingType;

  const SignDocumentScreen({
    super.key,
    required this.documentId,
    required this.certificate,
    required this.signatureType,
    required this.signingType,
  });

  @override
  Widget build(BuildContext context) {
    final body = BlocProvider<SignDocumentCubit>(
      create: (context) {
        return GetIt.instance.get<SignDocumentCubit>(
          param1: documentId,
          param2: certificate,
        )..signDocument(signatureType);
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
              context.read<SignDocumentCubit>().signDocument(signatureType);
            },
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.signDocumentTitle),
      ),
      body: SafeArea(
        child: body,
      ),
    );
  }

  void _onSuccess(BuildContext context, SignDocumentSuccessState state) {
    final screen = PresentSignedDocumentScreen(
      signedDocument: state.signedDocument,
      signingType: signingType,
    );
    final route = MaterialPageRoute(builder: (_) => screen);

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

      // TODO Add primary and secondary buttons
    );
  }

  Widget _getChild(BuildContext context, SignDocumentState state) {
    return switch (state) {
      SignDocumentInitialState _ => const LoadingContent(),
      SignDocumentLoadingState _ => const LoadingContent(),
      SignDocumentCanceledState _ => RetryView(
          headlineText: context.strings.signDocumentCanceledHeading,
          // TODO Use selectSigningCertificateCanceledBody
          // + add Primary Button: Skúsiť znovu
          // + add secondary button: Zrušiť podpisovanie
          onRetryRequested: onRetryRequested,
        ),
      SignDocumentErrorState state => ErrorContent(
          title: context.strings.signDocumentErrorHeading,
          error: state.error,
        ),
      SignDocumentSuccessState _ => const LoadingContent(), // see listener
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
