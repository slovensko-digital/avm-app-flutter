import 'package:autogram_sign/autogram_sign.dart'
    show VerifiableVisualizationResponseBody;

import 'server_document.dart';

/// [ServerDocument] to sign with its [visualization], against which the data
/// to sign are verified.
class DocumentToSign extends ServerDocument {
  /// Data objects covered by the signature, from which the document was
  /// visualized.
  final VerifiableVisualizationResponseBody visualization;

  const DocumentToSign(super.id, {super.server, required this.visualization});
}
