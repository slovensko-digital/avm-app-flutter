import 'dart:convert' show base64Decode;
import 'dart:io' show Directory, File;

import 'package:autogram_sign/autogram_sign.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../file_extensions.dart';
import '../ui/screens/present_signed_document_screen.dart';
import 'present_signed_document_state.dart';

export 'present_signed_document_state.dart';

/// Cubit for [PresentSignedDocumentScreen].
@injectable
class PresentSignedDocumentCubit extends Cubit<PresentSignedDocumentState> {
  static final _tsFormat = DateFormat('yyyyMMddHHmmss');
  static final _log = Logger("PresentSignedDocumentCubit");

  final SignDocumentResponse signedDocument;

  PresentSignedDocumentCubit({
    @factoryParam required this.signedDocument,
  }) : super(const PresentSignedDocumentInitialState());

  Future<void> saveDocument() async {
    emit(state.toLoading());

    try {
      final file = await _getTargetFile();
      final bytes = await Future.microtask(
        () => base64Decode(signedDocument.content),
      );

      await file.writeAsBytes(bytes);

      emit(state.toSuccess(file));

      _log.info("Document was saved into $file");
    } catch (error) {
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

  Future<File> _getTargetFile() async {
    // TODO Name "originalDocument_signed.ext" with suffix -NNN if file already exists
    var directory = await getApplicationDocumentsDirectory();

    if (directory.path.endsWith("app_flutter")) {
      directory = directory.parent;
    }

    final ts = _tsFormat.format(DateTime.timestamp());

    directory = Directory(p.join(directory.path, "documents", ts));

    await directory.create(recursive: true);

    final path = p.join(directory.path, signedDocument.filename);

    return File(path);
  }
}
