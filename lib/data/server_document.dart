import 'avm_server.dart';

/// Document with [id] stored on the AVM [server].
class ServerDocument {
  final String id;
  final AvmServer server;

  const ServerDocument(this.id, {this.server = AvmServer.official});

  @override
  String toString() {
    return "$runtimeType(id: $id, server: ${server.authority})";
  }
}
