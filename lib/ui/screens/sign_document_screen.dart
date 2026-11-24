import 'dart:developer' as developer;

import 'package:autogram_sign/autogram_sign.dart'
    show SignDocumentResponseBody, SignDocumentResponseBodyMimeType;
import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/sign_document_cubit.dart';
import '../../data/document_signing_type.dart';
import '../../data/document_to_sign.dart';
import '../../data/signature_type.dart';
import '../../strings_context.dart';
import '../../verification/document_verification_exception.dart';
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
  final DocumentToSign document;
  final Certificate certificate;
  final SignatureType signatureType;
  final DocumentSigningType signingType;
  final bool openFromDeepLink;

  const SignDocumentScreen({
    super.key,
    required this.document,
    required this.certificate,
    required this.signatureType,
    required this.signingType,
    required this.openFromDeepLink,
  });

  @override
  Widget build(BuildContext context) {
    final body = BlocProvider<SignDocumentCubit>(
      create: (context) {
        return GetIt.instance.get<SignDocumentCubit>(
          param1: document,
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
            onCancelRequested: () => _onCancelRequested(context),
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
      openFromDeepLink: openFromDeepLink,
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

  /// Cancels signing - goes back to MainScreen, not to the previous screen,
  /// from which the signing could be repeated.
  Future<void> _onCancelRequested(BuildContext context) async {
    Navigator.of(context).popUntil((route) => route.isFirst);

    if (openFromDeepLink && defaultTargetPlatform == TargetPlatform.android) {
      // back to the app, which opened the document, as after signing - see
      // PresentSignedDocumentScreen
      await SystemNavigator.pop();
    }
  }
}

/// [SignDocumentScreen] body.
class _Body extends StatelessWidget {
  final SignDocumentState state;
  final VoidCallback? onRetryRequested;
  final VoidCallback? onCancelRequested;

  const _Body({
    required this.state,
    this.onRetryRequested,
    this.onCancelRequested,
  });

  @override
  Widget build(BuildContext context) {
    final state = this.state;

    // signing of the document, which doesn't match, can only be canceled
    if (state case SignDocumentErrorState(
      error: DocumentVerificationException(isDocumentMismatch: true),
    )) {
      return Padding(
        padding: kScreenMargin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _getChild(context, state)),
            // Secondary button - as on PresentSignedDocumentScreen
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: kPrimaryButtonMinimumSize,
              ),
              onPressed: onCancelRequested,
              child: Text(context.strings.buttonCancelLabel),
            ),
          ],
        ),
      );
    }

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
  return _Body(
    state: const SignDocumentErrorState("Error message!"),
    onRetryRequested: () {
      developer.log('onRetryRequested');
    },
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'data to sign mismatch',
  type: SignDocumentScreen,
)
Widget previewDataToSignMismatchSignDocumentScreen(BuildContext context) {
  return _Body(
    state: const SignDocumentErrorState(
      DocumentVerificationException(
        DocumentVerificationFailure.dataToSignMismatch,
        "Digest of 'platba.txt' doesn't match the visualized document.",
      ),
    ),
    onCancelRequested: () {
      developer.log('onCancelRequested');
    },
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'success',
  type: SignDocumentScreen,
)
Widget previewSuccessSignDocumentScreen(BuildContext context) {
  return _Body(
    state: const SignDocumentSuccessState(
      SignDocumentResponseBody(
        filename: "document.pdf",
        mimeType: SignDocumentResponseBodyMimeType.applicationPdfBase64,
        content: "",
        issuedBy: "",
        signedBy: "",
      ),
    ),
    onRetryRequested: () {
      developer.log('onRetryRequested');
    },
  );
}
