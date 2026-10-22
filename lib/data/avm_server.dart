import 'package:flutter/foundation.dart' show immutable;

/// AVM server, which stores the document to sign.
///
/// Documents from other than the [official] server can be signed only when
/// they are visualized on the device, as such server can't be trusted.
@immutable
class AvmServer {
  /// Official AVM server.
  static const official = AvmServer("autogram.slovensko.digital");

  /// DNS name or IPv4 address; Dart [Uri] normalizes host to lower case.
  static final _hostPattern = RegExp(r"^[a-z0-9][a-z0-9.-]*$");

  /// Host with optional port of the server.
  final String authority;

  const AvmServer(this.authority);

  /// Creates [AvmServer] from host and port of the [uri].
  ///
  /// Throws [ArgumentError] when the [uri] has invalid host or contains user
  /// info, which could be used to mislead the user about the server.
  factory AvmServer.fromUri(Uri uri) {
    if (!_hostPattern.hasMatch(uri.host) || uri.userInfo.isNotEmpty) {
      throw ArgumentError.value(uri.toString(), "uri", "Invalid authority.");
    }

    // default HTTPS port in case of "avm" scheme
    final hasPort = uri.hasPort && uri.port != 443;

    return AvmServer(hasPort ? "${uri.host}:${uri.port}" : uri.host);
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
