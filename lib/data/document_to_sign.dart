import 'package:autogram_sign/autogram_sign.dart'
    show VerifiableVisualizationResponseBody;

/// Document to be signed - its id on the server and the data objects covered
/// by the signature, which were visualized to the user.
class DocumentToSign {
  final String id;
  final VerifiableVisualizationResponseBody visualization;

  const DocumentToSign({required this.id, required this.visualization});

  @override
  String toString() {
    return "$runtimeType(id: $id)";
  }
}
