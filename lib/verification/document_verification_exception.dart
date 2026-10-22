/// Reason why the document verification failed.
enum DocumentVerificationFailure {
  /// Data to sign doesn't contain digest of the visualized document.
  dataToSignMismatch,

  /// Visualized document is not the document selected by the user.
  localDocumentMismatch,

  /// Document from other than the official server can't be visualized on the
  /// device - only PDF, plain text and PNG or JPEG image can be.
  unsupportedDocumentType,

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
