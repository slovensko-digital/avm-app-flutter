import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../bloc/sign_document_cubit.dart';
import '../app_theme.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';
import '../widgets/retry_view.dart';
import 'present_signed_document_screen.dart';

/// Screen for signing the document by calling eID mSDK.
///
/// Uses [SignDocumentCubit].
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
    return BlocProvider<SignDocumentCubit>(
      create: (context) {
        return GetIt.instance.get<SignDocumentCubit>(
          param1: documentId,
          param2: certificate,
        )..signDocument(addTimeStamp);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Podpisovanie dokumentu")),
        body: Builder(builder: (context) {
          // Need outer Context to access Cubit
          return _Body(
            onRetryRequested: () {
              context.read<SignDocumentCubit>().signDocument(addTimeStamp);
            },
          );
        }),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final VoidCallback onRetryRequested;

  const _Body({required this.onRetryRequested});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignDocumentCubit, SignDocumentState>(
      listener: (context, state) {
        if (state is SignDocumentSuccessState) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => PresentSignedDocumentScreen(
                signedDocument: state.signedDocument,
              ),
            ),
            (route) {
              // Remove until MainScreen
              return route.settings.name == '/';
            },
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: kScreenMargin,
          child: _getChild(context, state),
        );
      },
    );
  }

  Widget _getChild(BuildContext context, SignDocumentState state) {
    return switch (state) {
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
      _ => Text("### $state ###"),
    };
  }
}
