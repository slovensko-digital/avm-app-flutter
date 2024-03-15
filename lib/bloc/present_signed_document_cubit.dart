import 'dart:convert' show base64Decode;
import 'dart:io' show File;

import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../app_service.dart';
import '../file_extensions.dart';
import '../ui/screens/present_signed_document_screen.dart';
import 'present_signed_document_state.dart';

export 'present_signed_document_state.dart';

/// Cubit for [PresentSignedDocumentScreen].
@injectable
class PresentSignedDocumentCubit extends Cubit<PresentSignedDocumentState> {
  static final _log = Logger("PresentSignedDocumentCubit");

  final AppService _appService;

  final SignDocumentResponse signedDocument;

  PresentSignedDocumentCubit({
    required AppService appService,
    @factoryParam required this.signedDocument,
  })  : _appService = appService,
        super(const PresentSignedDocumentInitialState());

  Future<void> saveDocument() async {
    _log.info("Saving signed document: ${signedDocument.filename}.");

    emit(state.toLoading());

    File? file;

    try {
      file = await _getTargetFile();
      final bytes = await Future.microtask(
        () => base64Decode(signedDocument.content),
      );

      await file.writeAsBytes(bytes);

      _log.info("Signed Document was saved into $file");

      emit(state.toSuccess(file));
    } catch (error, stackTrace) {
      _log.severe(
          "Error saving signed Document into $file.", error, stackTrace);

      emit(state.toError(error));
    }
  }

  /// Copies the file into TEMP directory so it's accessible by other apps.
  Future<File> getAccessibleFile() async {
    final state = (this.state as PresentSignedDocumentSuccessState);

    final directory = await getTemporaryDirectory();
    final sourceFile = state.file;
    final path = p.join(directory.path, sourceFile.basename);

    return sourceFile.copy(path);
  }

  /// Returns target [File] where to save new file from [signedDocument].
  Future<File> _getTargetFile() async {
    final directory = await _appService.getDownloadsDirectory();
    final path = p.join(directory.path, signedDocument.filename);

    return File(path);
  }
}
