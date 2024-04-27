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
  });
}
