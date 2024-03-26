import 'dart:convert' show base64Decode;
import 'dart:io' show File;

import 'package:autogram_sign/autogram_sign.dart' show SignDocumentResponseBody;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart' show DateFormat;
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
  static final _tsDateFormat = DateFormat('yyyyMMddHHmmss');

  final AppService _appService;

  final SignDocumentResponseBody signedDocument;

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

  /// Gets the [File] for share action.
  Future<File> getShareableFile() async {
    final state = this.state;

    if (state is PresentSignedDocumentSuccessState) {
      final file = state.file;

      if (await file.exists()) {
        return file;
      }
    }

    final name = signedDocument.filename;
    final directory = await getTemporaryDirectory();
    final path = p.join(directory.path, name);
    final bytes = await Future.microtask(
      () => base64Decode(signedDocument.content),
    );
    final file = File(path);

    return file.writeAsBytes(bytes, flush: true);
  }

  /// Returns target [File] where to save new file from [signedDocument].
  ///
  /// See also:
  ///  - [getTargetFileName]
  Future<File> _getTargetFile() async {
    final directory = await _appService.getDocumentsDirectory();
    final name = getTargetFileName(signedDocument.filename);
    final path = p.join(directory.path, name);

    return File(path);
  }

  /// Gets the target file name.
  /// Drops suffix and adds timestamp.
  @visibleForTesting
  static String getTargetFileName(
    String name, [
    // TODO This should get exact DateTime from previous cubit when it was really signed
    // SignDocumentCubit signingTime
    ValueGetter<DateTime> clock = DateTime.now,
  ]) {
    // NAME-signed-pades-baseline-b.pdf

    // 1. Drop container type from name
    final file = File(name);
    final cleanName = file.basenameWithoutExtension
        .replaceAll(RegExp('-signed-[cxp]ades-baseline-[bt]'), '-signed');
    final ext = file.extension;

    // 2. Get timestamp
    final date = clock();
    final ts = _tsDateFormat.format(date);

    // 3. Final format
    return "$cleanName-$ts$ext";
  }
}
