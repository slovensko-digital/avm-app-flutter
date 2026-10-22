/// Reason why the document verification failed.
enum DocumentVerificationFailure {
  /// Data to sign doesn't contain digest of the visualized document.
  dataToSignMismatch,

  /// Visualized document is not the document selected by the user.
  localDocumentMismatch,

  /// XSLT transformation doesn't match the digest in the XML Datacontainer.
  transformationMismatch,

  /// Data received from the server are malformed or not supported.
  unsupportedData,
}

/// Thrown when the document, which will be signed, can't be verified.
///
/// The [message] is technical description for logs, user should be informed
/// by the [reason].
class DocumentVerificationException implements Exception {
  final DocumentVerificationFailure reason;
  final String message;

  const DocumentVerificationException(this.reason, this.message);

  @override
  String toString() {
    return "DocumentVerificationException(reason: ${reason.name}, message: $message)";
  }
}
