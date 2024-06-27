/// Parser app Deep Link URIs.
///
/// It has to conform:
///  - schema: "https" or "avm"
///  - authority: "autogram.slovensko.digital"
///  - path: "/api/v1/"
///
/// Throws [ArgumentError] in case of invalid or unknown schema or structure.
// TODO Move this code + test into autogram_sign module; however, it needs to check uri.authority, so it should be function on IAutogramService
DeepLinkAction parseDeepLinkAction(Uri uri) {
  // Validate schema, authority and path
  switch (uri.scheme) {
    case "https" || "avm":
      break;
    default:
      throw ArgumentError.value(
          uri.toString(), "uri", "Invalid or unsupported scheme.");
  }

  if (uri.authority != "autogram.slovensko.digital") {
    throw ArgumentError.value(
        uri.toString(), "uri", "Invalid or unsupported authority.");
  }

  if (!uri.path.startsWith("/api/v1/")) {
    throw ArgumentError.value(
        uri.toString(), "uri", "Invalid or unsupported path.");
  }

  return switch (uri.path) {
    "/api/v1/qr-code" => () {
        if (!uri.queryParameters.containsKey("guid")) {
          throw ArgumentError.value(
              uri.toString(), "uri", '"guid" param is missing a value.');
        }

        if (!uri.queryParameters.containsKey("key")) {
          throw ArgumentError.value(
              uri.toString(), "uri", '"key" param is missing a value.');
        }

        return SignRemoteDocumentAction(
          guid: uri.queryParameters["guid"]!,
          key: uri.queryParameters["key"]!,
          integration: uri.queryParameters["integration"],
          pushkey: uri.queryParameters["pushkey"],
        );
      }(),
    _ => throw ArgumentError.value(
        uri.toString(), "uri", "Invalid or unsupported URI."),
  };
}

/// Supported Deep Link action.
sealed class DeepLinkAction {}

/// Action to sign remote document.
class SignRemoteDocumentAction extends DeepLinkAction {
  final String guid;
  final String key;
  final String? integration;
  final String? pushkey;

  SignRemoteDocumentAction({
    required this.guid,
    required this.key,
    required this.integration,
    required this.pushkey,
  });

  @override
  String toString() {
    return "$runtimeType(guid: $guid)";
  }
}
