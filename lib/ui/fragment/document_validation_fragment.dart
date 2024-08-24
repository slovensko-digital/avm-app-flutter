import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/document_validation_cubit.dart';
import '../../di.dart';
import '../widgets/document_validation_strip.dart';

/// Executes Document validation and displays output in [DocumentValidationStrip]
///
/// Uses [DocumentValidationCubit].
class DocumentValidationFragment extends StatelessWidget {
  // TODO Stateful widget?
  final String documentId;

  const DocumentValidationFragment({
    super.key,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DocumentValidationCubit>(
      create: (context) {
        return getIt.get<DocumentValidationCubit>()
          ..validateDocument(documentId);
      },
      child: BlocBuilder<DocumentValidationCubit, DocumentValidationState>(
        builder: _buildContent,
      ),
    );
  }

  Widget _buildContent(BuildContext context, DocumentValidationState state) {
    return switch (state) {
      DocumentValidationInitialState _ => const DocumentValidationStrip(
          value: DocumentValidationStripValue.loading(),
        ),
      DocumentValidationLoadingState _ => const DocumentValidationStrip(
          value: DocumentValidationStripValue.loading(),
        ),
      DocumentValidationSuccessState state => DocumentValidationStrip(
          value: DocumentValidationStripValue.value(
            validCount: state.response.signatures?.length ?? 0,
            invalidCount: state.response.signatures?.length ?? 0,
          ),
          onTap: () {
            // TODO Handle tap event
          },
        ),
      DocumentValidationErrorState _ =>
        const SizedBox.shrink(), // TODO Show error in this panel.
    };
  }
}
