/// Parser app Deep Link URIs.
///
/// It has to conform:
///  - schema: "https" or "avm"
///  - authority: "autogram.slovensko.digital"
///  - path: "/api/v1/"
///
/// Throws [ArgumentError] in case of invalid or unknown schema or structure.
// TODO PAIRING Move this code + test into autogram_sign module; however, it needs to check uri.authority, so it should be function on IAutogramService
DeepLinkAction parseDeepLinkAction(Uri uri) {
  // Validate schema, authority and path
  switch (uri.scheme) {
    case "https" || "avm":
      break;
    default:
      throw ArgumentError.value(
        uri.toString(),
        "uri",
        "Invalid or unsupported scheme.",
      );
  }

  // TODO PAIRING Check authority dynamically from baseUrl
  if (uri.authority != "autogram.slovensko.digital") {
    throw ArgumentError.value(
      uri.toString(),
      "uri",
      "Invalid or unsupported authority.",
    );
  }

  if (!uri.path.startsWith("/api/v1/")) {
    throw ArgumentError.value(
      uri.toString(),
      "uri",
      "Invalid or unsupported path.",
    );
  }

  // https://autogram.slovensko.digital/api/v1/qr-code-register?integration=eyJhbGciOiJFUzI1NiJ9.eyJqdGkiOiI3ZTBjMTBkNC1kY2FmLTRhNTYtYjA0YS1jMmIzNzc0ODM1YjciLCJzdWIiOiIxMTdhMGIwNC1mM2Q0LTQ5OWMtYTYxMy02YzY1MmU0ODZmMDEiLCJhdWQiOiJkZXZpY2UiLCJleHAiOjE3NzQ3MTg1Nzl9.tkc5qJwpEz2LPRnmhZVEPc_FM_iBRduinfIjUr8OzE1kgMJfuEZ8Kh4M2DGPXzSF-x5SgR5wXsXw_ZmW210zYA

  return switch (uri.path) {
    "/api/v1/qr-code" => () {
      if (!uri.queryParameters.containsKey("guid")) {
        throw ArgumentError.value(
          uri.toString(),
          "uri",
          '"guid" param is missing a value.',
        );
      }

      if (!uri.queryParameters.containsKey("key")) {
        throw ArgumentError.value(
          uri.toString(),
          "uri",
          '"key" param is missing a value.',
        );
      }

      return SignRemoteDocumentAction(
        guid: uri.queryParameters["guid"]!,
        key: uri.queryParameters["key"]!,
        integration: uri.queryParameters["integration"],
      );
    }(),
    _ => throw ArgumentError.value(
      uri.toString(),
      "uri",
      "Invalid or unsupported URI.",
    ),
  };
}

/// Supported Deep Link action.
sealed class DeepLinkAction {}

// TODO PAIRING Create type to RegisterIntegrationAction

/// Action to sign remote document.
class SignRemoteDocumentAction extends DeepLinkAction {
  final String guid;
  final String key;
  final String? integration;

  SignRemoteDocumentAction({
    required this.guid,
    required this.key,
    required this.integration,
  });

  @override
  String toString() {
    return "$runtimeType(guid: $guid)";
  }
}
