import 'package:autogram_sign/autogram_sign.dart'
    show
        DocumentValidationResponseBody,
        DocumentValidationResponseBody$Signatures$Item,
        DocumentValidationResponseBody$Signatures$ItemValidationResult;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/document_validation_cubit.dart';
import '../../di.dart';
import '../widgets/document_validation_strip.dart';

typedef _ValidationResult
    = DocumentValidationResponseBody$Signatures$ItemValidationResult;

/// Executes Document validation and displays output in [DocumentValidationStrip].
///
/// Uses [DocumentValidationCubit].
class DocumentValidationFragment extends StatefulWidget {
  final String documentId;
  final ValueSetter<DocumentValidationResponseBody>
      onShowDocumentValidationInfoRequested;

  const DocumentValidationFragment({
    super.key,
    required this.documentId,
    required this.onShowDocumentValidationInfoRequested,
  });

  @override
  State<DocumentValidationFragment> createState() =>
      _DocumentValidationFragmentState();
}

class _DocumentValidationFragmentState
    extends State<DocumentValidationFragment> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DocumentValidationCubit>(
      create: (context) {
        return getIt.get<DocumentValidationCubit>()
          ..validateDocument(widget.documentId);
      },
      child: BlocBuilder<DocumentValidationCubit, DocumentValidationState>(
        builder: _buildContent,
      ),
    );
  }

  Widget _buildContent(BuildContext context, DocumentValidationState state) {
    if (_hidden) {
      // TODO Animate height from 100% to 0
      return const SizedBox.shrink();
    }

    return switch (state) {
      DocumentValidationInitialState _ => const DocumentValidationStrip(
          value: DocumentValidationStripValue.loading(),
        ),
      DocumentValidationLoadingState _ => const DocumentValidationStrip(
          value: DocumentValidationStripValue.loading(),
        ),
      DocumentValidationNotSignedState _ => DocumentValidationStrip(
          value: const DocumentValidationStripValue.none(),
          onTap: () {
            setState(() {
              _hidden = true;
            });
          },
        ),
      DocumentValidationSuccessState state => DocumentValidationStrip(
          value: DocumentValidationStripValue.value(
            failedCount: state.response.failedCount,
            indeterminateCount: state.response.indeterminateCount,
            passedCount: state.response.passedCount,
          ),
          onTap: () {
            widget.onShowDocumentValidationInfoRequested.call(state.response);
          },
        ),
      DocumentValidationErrorState _ => const SizedBox.shrink(),
      // TODO Show error in this panel - red background with message
    };
  }
}

/// A set of extensions on [DocumentValidationResponseBody].
extension _DocumentValidationResponseBodyExtensions
    on DocumentValidationResponseBody {
  List<DocumentValidationResponseBody$Signatures$Item> get signaturesOrEmpty =>
      (signatures ?? []);

  int get failedCount => signaturesOrEmpty
      .where((s) => s.validationResult == _ValidationResult.totalFailed)
      .length;

  int get indeterminateCount => signaturesOrEmpty
      .where((s) => s.validationResult == _ValidationResult.indeterminate)
      .length;

  int get passedCount => signaturesOrEmpty
      .where((s) => s.validationResult == _ValidationResult.totalPassed)
      .length;
}
