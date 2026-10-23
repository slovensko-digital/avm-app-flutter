import 'package:autogram/data/avm_server.dart';
import 'package:autogram/deep_links.dart';
import 'package:test/test.dart';

/// Tests for the [parseDeepLinkAction] function.
void main() {
  group('parseDeepLinkAction', () {
    test('parseDeepLinkAction throws ArgumentError for invalid URIs', () {
      expect(
        () => parseDeepLinkAction(Uri.parse("")),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'uri')),
      );

      expect(
        () => parseDeepLinkAction(Uri.parse("foo://bar")),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'uri')),
      );

      expect(
        () => parseDeepLinkAction(
            Uri.parse("avm://autogram.slovensko.digital/test")),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'uri')),
      );
    });

    test('parseDeepLinkAction returns value for valid URI', () {
      final uri = Uri.parse(
          "https://autogram.slovensko.digital/api/v1/qr-code?guid=e7e95411-66a1-d401-e063-0a64dbb6b796&key=EeESAfZQh9OTf5qZhHZtgaDJpYtxZD6TIOQJzRgRFgQ%3D&pushkey=R%2FrfN%2Bz129w1H2iftbr1GOKXdC3OxSJU9PZeHs%2BW7ts%3D&integration=eyJhbGciOiJFUzI1NiJ9.eyJzdWIiOiI3OGQ5MWRlNy0xY2MyLTQwZTQtOWE3MS0zODU4YjRmMDMxOWQiLCJleHAiOjE3MTI5MDk3MjAsImp0aSI6IjAwZTAxN2Y1LTI4MTAtNDkyNS04ODRlLWNiN2FhZDAzZDFhNiIsImF1ZCI6ImRldmljZSJ9.7Op6W2BvbX2_mgj9dkz1IiolEsQ1Z2a0AzpS5bj4pcG3CJ4Z8j9W3RQE95wrAj3t6nmd9JaGZSlCJNSV_myyLQ");
      final value = parseDeepLinkAction(uri);

      expect(value, const TypeMatcher<SignRemoteDocumentAction>());
      expect((value as SignRemoteDocumentAction), isNotNull);
      expect(value.guid, "e7e95411-66a1-d401-e063-0a64dbb6b796");
      expect((value).key, "EeESAfZQh9OTf5qZhHZtgaDJpYtxZD6TIOQJzRgRFgQ=");
      expect((value).pushkey, "R/rfN+z129w1H2iftbr1GOKXdC3OxSJU9PZeHs+W7ts=");
      expect((value).integration,
          "eyJhbGciOiJFUzI1NiJ9.eyJzdWIiOiI3OGQ5MWRlNy0xY2MyLTQwZTQtOWE3MS0zODU4YjRmMDMxOWQiLCJleHAiOjE3MTI5MDk3MjAsImp0aSI6IjAwZTAxN2Y1LTI4MTAtNDkyNS04ODRlLWNiN2FhZDAzZDFhNiIsImF1ZCI6ImRldmljZSJ9.7Op6W2BvbX2_mgj9dkz1IiolEsQ1Z2a0AzpS5bj4pcG3CJ4Z8j9W3RQE95wrAj3t6nmd9JaGZSlCJNSV_myyLQ");
    });

    test('parseDeepLinkAction returns value for integration register URI', () {
      final uri = Uri.parse(
          "https://autogram.slovensko.digital/api/v1/qr-code-register?integration=eyJhbGciOiJFUzI1NiJ9.eyJhdWQiOiJkZXZpY2UifQ.sig");
      final value = parseDeepLinkAction(uri);

      expect(value, const TypeMatcher<RegisterIntegrationAction>());
      expect((value as RegisterIntegrationAction).integration,
          "eyJhbGciOiJFUzI1NiJ9.eyJhdWQiOiJkZXZpY2UifQ.sig");
    });

    test('parseDeepLinkAction returns other server without pairing', () {
      final value = parseDeepLinkAction(Uri.parse(
          "https://AVM.example.org:8443/api/v1/qr-code?guid=1&key=2&integration=jwt&pushkey=3"));

      expect(value, const TypeMatcher<SignRemoteDocumentAction>());
      value as SignRemoteDocumentAction;
      expect(value.guid, "1");
      expect(value.key, "2");
      expect(value.server, const AvmServer("avm.example.org:8443"));
      expect(value.server.isOfficial, isFalse);
      expect(value.server.baseUrl,
          Uri.parse("https://avm.example.org:8443/api/v1"));
      expect(value.integration, isNull);
      expect(value.pushkey, isNull);
    });

    test('parseDeepLinkAction returns official server', () {
      for (final uri in [
        "https://autogram.slovensko.digital/api/v1/qr-code?guid=1&key=2",
        "avm://autogram.slovensko.digital:443/api/v1/qr-code?guid=1&key=2",
      ]) {
        final value = parseDeepLinkAction(Uri.parse(uri));

        expect((value as SignRemoteDocumentAction).server, AvmServer.official,
            reason: uri);
        expect(value.server.isOfficial, isTrue);
      }
    });

    test('parseDeepLinkAction returns server without user info', () {
      final value = parseDeepLinkAction(Uri.parse(
          "https://autogram.slovensko.digital@avm.example.org/api/v1/qr-code?guid=1&key=2"));

      expect((value as SignRemoteDocumentAction).server,
          const AvmServer("avm.example.org"));
      expect(value.server.isOfficial, isFalse);
    });

    test('parseDeepLinkAction throws for URI without server', () {
      expect(
        () => parseDeepLinkAction(
            Uri.parse("https:///api/v1/qr-code?guid=1&key=2")),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'uri')),
      );
    });

    test('parseDeepLinkAction throws for pairing with other server', () {
      expect(
        () => parseDeepLinkAction(Uri.parse(
            "https://avm.example.org/api/v1/qr-code-register?integration=jwt")),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'uri')),
      );
    });

    test('parseDeepLinkAction throws for integration register URI without token',
        () {
      expect(
        () => parseDeepLinkAction(Uri.parse(
            "avm://autogram.slovensko.digital/api/v1/qr-code-register")),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'uri')),
      );
    });
  });

  group('getPairingTokenIntegrationId', () {
    test('getPairingTokenIntegrationId returns sub claim', () {
      // Payload: {"sub":"78d91de7-1cc2-40e4-9a71-3858b4f0319d","exp":1712909720,"jti":"00e017f5-2810-4925-884e-cb7aad03d1a6","aud":"device"}
      const token =
          "eyJhbGciOiJFUzI1NiJ9.eyJzdWIiOiI3OGQ5MWRlNy0xY2MyLTQwZTQtOWE3MS0zODU4YjRmMDMxOWQiLCJleHAiOjE3MTI5MDk3MjAsImp0aSI6IjAwZTAxN2Y1LTI4MTAtNDkyNS04ODRlLWNiN2FhZDAzZDFhNiIsImF1ZCI6ImRldmljZSJ9.7Op6W2BvbX2_mgj9dkz1IiolEsQ1Z2a0AzpS5bj4pcG3CJ4Z8j9W3RQE95wrAj3t6nmd9JaGZSlCJNSV_myyLQ";

      expect(getPairingTokenIntegrationId(token),
          "78d91de7-1cc2-40e4-9a71-3858b4f0319d");
    });

    test('getPairingTokenIntegrationId returns null for invalid token', () {
      expect(getPairingTokenIntegrationId(""), isNull);
      expect(getPairingTokenIntegrationId("a.b"), isNull);
      expect(getPairingTokenIntegrationId("a.!!!.c"), isNull);
      // Payload: {"aud":"device"}
      expect(getPairingTokenIntegrationId("e30.eyJhdWQiOiJkZXZpY2UifQ.sig"),
          isNull);
    });
  });
}
