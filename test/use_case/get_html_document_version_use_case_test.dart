import 'package:autogram/use_case/get_html_document_version_use_case.dart';
import 'package:test/test.dart';

/// Tests for the [GetHtmlDocumentVersionUseCase] class.
void main() {
  group('GetDocumentVersionUseCase', () {
    test('parseVersion throws ArgumentError for empty HTML', () {
      expect(
        () => GetHtmlDocumentVersionUseCase.parseVersion(""),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'text')),
      );

      expect(
        () => GetHtmlDocumentVersionUseCase.parseVersion('<html lang="en" />'),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'text')),
      );
    });

    test(
        'parseVersion throws ArgumentError for HTML with missing or invalid meta',
        () {
      expect(
        () => GetHtmlDocumentVersionUseCase.parseVersion(
          '<html lang="en"><head><title/></head></html>',
        ),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'text')),
      );

      expect(
        () => GetHtmlDocumentVersionUseCase.parseVersion("""
          <html lang="en">
            <head>
              <title />
              <meta content="utf-8" http-equiv="encoding">
            </head>
          </html>
        """),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'text')),
      );
      expect(
        () => GetHtmlDocumentVersionUseCase.parseVersion("""
          <html lang="en">
            <head>
              <title />
              <meta name="version">
            </head>
          </html>
        """),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'text')),
      );
      expect(
        () => GetHtmlDocumentVersionUseCase.parseVersion("""
          <html lang="en">
            <head>
              <title />
              <meta name="version" content="">
            </head>
          </html>
        """),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'text')),
      );
    });

    test('parseVersion returns value for valid meta with value', () {
      expect(
        () => GetHtmlDocumentVersionUseCase.parseVersion(
          '<html lang="en"><head><title></title></head></html>',
        ),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'text')),
      );

      expect(
        () => GetHtmlDocumentVersionUseCase.parseVersion("""
          <html lang="en">
            <head>
              <title></title>
              <meta content="utf-8" http-equiv="encoding">
            </head>
          </html>
        """),
        throwsA(predicate((e) => e is ArgumentError && e.name == 'text')),
      );
      expect(
        GetHtmlDocumentVersionUseCase.parseVersion("""
          <html lang="en">
            <head>
              <title></title>
              <meta name="version" content="2024-05-20T12:43:33Z">
            </head>
          </html>
        """),
        equals("2024-05-20T12:43:33Z"),
      );
    });
  });
}
