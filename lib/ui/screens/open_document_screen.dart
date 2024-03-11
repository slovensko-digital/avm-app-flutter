import 'dart:async';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

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
/// Navigates next to [PreviewDocumentScreen].
class OpenDocumentScreen extends StatelessWidget {
  final FutureOr<File> file;

  const OpenDocumentScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Otváranie dokumentu"),
      ),
      body: _Body(file: file),
    );
  }
}

class _Body extends StatelessWidget {
  final FutureOr<File> file;

  const _Body({required this.file});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateDocumentCubit>(
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
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => PreviewDocumentScreen(
                  file: state.file,
                  documentId: state.documentId,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
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
        },
      ),
    );
  }
}
