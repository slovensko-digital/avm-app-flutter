import 'package:autogram_sign/autogram_sign.dart'
    show DocumentValidationResponseBody;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/document_validation_cubit.dart';
import '../../di.dart';
import '../widgets/document_validation_strip.dart';

/// Executes Document validation and displays output in [DocumentValidationStrip]
///
/// Uses [DocumentValidationCubit].
class DocumentValidationFragment extends StatelessWidget {
  // TODO Consider migrating to to stateful widget becasue of Cubit
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
      DocumentValidationNotSignedState _ => const DocumentValidationStrip(
          value: DocumentValidationStripValue.none(),
        ),
      DocumentValidationSuccessState state => DocumentValidationStrip(
          value: DocumentValidationStripValue.value(
            validCount: state.response?.validSignaturesCount ?? 0,
            invalidCount: state.response?.invalidSignaturesCount ?? 0,
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

extension _DocumentValidationResponseBodyExtensions
    on DocumentValidationResponseBody {
  int? get validSignaturesCount => signatures
      ?.where((s) => s.validationResult.code == 0 /* TOTAL_PASSED */)
      .length;
  int? get invalidSignaturesCount => signatures
      ?.where((s) => s.validationResult.code != 0 /* NOT TOTAL_PASSED */)
      .length;
}
