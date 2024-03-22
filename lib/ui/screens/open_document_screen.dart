import 'dart:async';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/create_document_cubit.dart';
import '../../data/settings.dart';
import '../app_theme.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';
import 'preview_document_screen.dart';

/// Screen for opening single document from [file].
///
/// Uses [CreateDocumentCubit].
///
/// Navigates next to [PreviewDocumentScreen] on success.
class OpenDocumentScreen extends StatelessWidget {
  final FutureOr<File> file;

  const OpenDocumentScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final body = BlocProvider<CreateDocumentCubit>(
      create: (context) {
        final settings = context.read<ISettings>();
        final pdfSigningOption = settings.signingPdfContainer.value;

        return GetIt.instance.get<CreateDocumentCubit>(
          param1: file,
          param2: pdfSigningOption,
        )..createDocument();
      },
      child: BlocConsumer<CreateDocumentCubit, CreateDocumentState>(
        listener: (context, state) {
          // On success move to next screen replacing this
          if (state is CreateDocumentSuccessState) {
            _onSuccess(context, state);
          }
        },
        builder: (context, state) {
          return _Body(state: state);
        },
      ),
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Otváranie dokumentu"),
        ),
        body: body,
      ),
    );
  }

  void _onSuccess(BuildContext context, CreateDocumentSuccessState state) {
    final screen = PreviewDocumentScreen(
      file: state.file,
      documentId: state.documentId,
    );
    final route = MaterialPageRoute(
      builder: (context) => screen,
    );

    Navigator.of(context).pushReplacement(route);
  }
}

/// [OpenDocumentScreen] body.
class _Body extends StatelessWidget {
  final CreateDocumentState state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    final child = switch (state) {
      CreateDocumentErrorState state => ErrorContent(
          title: "Chyba pri vytváraní dokumentu",
          error: state.error,
        ),
      _ => const LoadingContent(),
    };

    return Padding(
      padding: kScreenMargin,
      child: child,
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'loading',
  type: OpenDocumentScreen,
)
Widget previewLoadingOpenDocumentScreen(BuildContext context) {
  return const _Body(
    state: CreateDocumentLoadingState(),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'error',
  type: OpenDocumentScreen,
)
Widget previewErrorOpenDocumentScreen(BuildContext context) {
  return const _Body(
    state: CreateDocumentErrorState("Error message!"),
  );
}
