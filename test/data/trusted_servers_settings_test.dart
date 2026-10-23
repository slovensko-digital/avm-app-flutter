import 'package:autogram/data/avm_server.dart';
import 'package:autogram/data/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notified_preferences/notified_preferences.dart';

/// Tests for the [TrustedServersSettings] extension.
void main() {
  const server = AvmServer("avm.example.org");

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('official server is always trusted', () async {
    final settings = await Settings.create();

    expect(settings.isTrustedServer(AvmServer.official), isTrue);
    expect(settings.isTrustedServer(server), isFalse);
  });

  test('trusted server is remembered', () async {
    final settings = await Settings.create();

    settings.trustServer(server);
    settings.trustServer(server);
    settings.trustServer(AvmServer.official);

    expect(settings.isTrustedServer(server), isTrue);
    expect(settings.trustedServers.value, ["avm.example.org"]);

    final created = await Settings.create();
    expect(created.isTrustedServer(server), isTrue);
    expect(
      created.isTrustedServer(const AvmServer("avm.example.org:8443")),
      isFalse,
    );
  });

  test('distrusted server is forgotten', () async {
    final settings = await Settings.create();
    const other = AvmServer("podpis.example.sk");

    settings.trustServer(server);
    settings.trustServer(other);
    settings.distrustServer(server);

    expect(settings.isTrustedServer(server), isFalse);
    expect(settings.trustedServers.value, ["podpis.example.sk"]);

    final created = await Settings.create();
    expect(created.isTrustedServer(server), isFalse);
    expect(created.isTrustedServer(other), isTrue);
  });
}
