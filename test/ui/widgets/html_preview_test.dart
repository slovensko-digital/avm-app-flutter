import 'package:autogram/ui/widgets/html_preview.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the [HtmlPreview] class.
void main() {
  group('HtmlPreview.withContentSecurityPolicy', () {
    const meta =
        '<meta http-equiv="Content-Security-Policy" '
        'content="${HtmlPreview.contentSecurityPolicy}">';

    test('adds policy at the beginning of HTML without DOCTYPE', () {
      expect(
        HtmlPreview.withContentSecurityPolicy("<html><body/></html>"),
        "$meta<html><body/></html>",
      );
    });

    test('adds policy after DOCTYPE', () {
      const doctype =
          '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" '
          '"http://www.w3.org/TR/html4/strict.dtd">';

      expect(
        HtmlPreview.withContentSecurityPolicy("$doctype\n<html></html>"),
        "$doctype$meta\n<html></html>",
      );
    });

    test('adds policy after XML declaration, comments and DOCTYPE', () {
      const prolog =
          '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!-- a -- comment -->\n<!--other--><!doctype html>';

      expect(
        HtmlPreview.withContentSecurityPolicy("$prolog<html></html>"),
        "$prolog$meta<html></html>",
      );
    });

    test('does not treat DOCTYPE in the content as the document type', () {
      const html =
          "<html><body>&lt;!DOCTYPE html&gt;<!DOCTYPE x></body></html>";

      expect(HtmlPreview.withContentSecurityPolicy(html), "$meta$html");
    });

    test('handles many comments without DOCTYPE in linear time', () {
      final html = "${"<!-- c -->" * 10000}<html></html>";

      expect(HtmlPreview.withContentSecurityPolicy(html), "$meta$html");
    });
  });
}
