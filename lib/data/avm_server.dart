import 'package:flutter/foundation.dart' show immutable;

/// AVM server, which stores the document to sign.
///
/// Documents from other than the [official] server can be signed only when
/// they are visualized on the device, as such server can't be trusted.
@immutable
class AvmServer {
  /// Official AVM server.
  static const official = AvmServer("autogram.slovensko.digital");

  /// Host with optional port of the server.
  final String authority;

  const AvmServer(this.authority);

  /// Creates [AvmServer] from host and port of the [uri].
  ///
  /// Throws [ArgumentError] when the [uri] has no host.
  factory AvmServer.fromUri(Uri uri) {
    if (uri.host.isEmpty) {
      throw ArgumentError.value(uri.toString(), "uri", "Missing host.");
    }

    // HTTPS also for "avm" scheme, so its default port is omitted
    final url = Uri(
      scheme: "https",
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    );

    return AvmServer(url.authority);
  }

  /// Whether this is the [official] server.
  bool get isOfficial => this == official;

  /// Base URL of the server API, always over HTTPS.
  Uri get baseUrl => Uri.parse("https://$authority/api/v1");

  @override
  bool operator ==(Object other) {
    return other is AvmServer && other.authority == authority;
  }

  @override
  int get hashCode => authority.hashCode;

  @override
  String toString() {
    return "$runtimeType($authority)";
  }
}
