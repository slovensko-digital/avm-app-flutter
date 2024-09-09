import 'package:autogram_sign/autogram_sign.dart'
    show
        DocumentValidationResponseBody,
        DocumentValidationResponseBody$Signatures$ItemValidationResult;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/document_validation_cubit.dart';
import '../../di.dart';
import '../widgets/document_validation_strip.dart';

/// Executes Document validation and displays output in [DocumentValidationStrip].
///
/// Uses [DocumentValidationCubit].
class DocumentValidationFragment extends StatelessWidget {
  // TODO Consider migrating to to stateful widget becasue of Cubit
  final String documentId;
  final ValueSetter<DocumentValidationResponseBody>
      onShowDocumentValidationInfoRequested;

  const DocumentValidationFragment({
    super.key,
    required this.documentId,
    required this.onShowDocumentValidationInfoRequested,
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
            validCount: state.response.validSignaturesCount ?? 0,
            invalidCount: state.response.invalidSignaturesCount ?? 0,
          ),
          onTap: () {
            onShowDocumentValidationInfoRequested.call(state.response);
          },
        ),
      DocumentValidationErrorState _ => const SizedBox.shrink(),
      // TODO Show error in this panel - red background with message
    };
  }
}

extension _DocumentValidationResponseBodyExtensions
    on DocumentValidationResponseBody {
  int? get validSignaturesCount => signatures
      ?.where((s) =>
          s.validationResult ==
          DocumentValidationResponseBody$Signatures$ItemValidationResult
              .totalPassed)
      .length;
  int? get invalidSignaturesCount => signatures
      ?.where((s) =>
          s.validationResult !=
          DocumentValidationResponseBody$Signatures$ItemValidationResult
              .totalPassed)
      .length;
}
