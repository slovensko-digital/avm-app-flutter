import 'dart:convert' show base64Decode;
import 'dart:io' show File, Platform;

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
///
/// Allows saving document into public directory or getting [File] instance
/// which can be shared.
@injectable
class PresentSignedDocumentCubit extends Cubit<PresentSignedDocumentState> {
  static final _log = Logger((PresentSignedDocumentCubit).toString());
  static final _tsDateFormat = DateFormat('yyyyMMddHHmmss');

  final AppService _appService;

  final SignDocumentResponseBody signedDocument;

  PresentSignedDocumentCubit({
    required AppService appService,
    @factoryParam required this.signedDocument,
  })  : _appService = appService,
        super(const PresentSignedDocumentInitialState());

  /// Saves [signedDocument] into public directory.
  Future<void> saveDocument() async {
    // TODO REDACT
    _log.info("Saving signed document: ${signedDocument.filename}.");

    emit(state.toLoading());

    File? file;

    try {
      file = await _getTargetPath().then((path) => File(path));
      // TODO Catch and still allow sharing
      // Need to change PresentSignedDocumentSuccessState impl. to allow File?
      await _saveDocumentIntoFile(file!);

      // TODO REDACT
      _log.info("Signed Document was saved into $file");

      emit(state.toSuccess(file));
    } catch (error, stackTrace) {
      // TODO REDACT
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
    final file = File(path);

    await _saveDocumentIntoFile(file);

    return file;
  }

  /// Returns file path, where [signedDocument] content should be saved.
  ///
  /// See also:
  ///  - [getTargetFileName]
  Future<String> _getTargetPath() async {
    final directory = await _appService.getDocumentsDirectory();

    // Attempt to create Directory if not exists
    if (!(await directory.exists()) && Platform.isAndroid) {
      await directory.create(recursive: true);
    }

    final name = getTargetFileName(signedDocument.filename);

    return p.join(directory.path, name);
  }

  /// Saves [signedDocument] content into given [file].
  Future<void> _saveDocumentIntoFile(File file) {
    return Future.microtask(() => base64Decode(signedDocument.content))
        .then((bytes) => file.writeAsBytes(bytes, flush: true));
  }

  /// Gets the target file name.
  /// Drops suffix and adds timestamp.
  @visibleForTesting
  static String getTargetFileName(
    String name, [
    // TODO This should get exact DateTime from previous cubit when it was actually signed
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
