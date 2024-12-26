import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html show parse;
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

/// Gets the HTML document version by reading value
/// from "version" HTML `meta` tag.
@lazySingleton
class GetHtmlDocumentVersionUseCase {
  static final http.Client _client = http.Client();

  /// Gets the document version on this [url].
  Future<String> call(Uri url) async {
    final text = await _getHtml(url);

    if (text.isEmpty) {
      throw ArgumentError.value(
          url, "url", "GET on URL yields no text content.");
    }

    return parseVersion(text);
  }

  /// Gets the HTML content from given [url].
  static Future<String> _getHtml(Uri url) async {
    final response = await _client.get(url);

    return response.body;
  }

  /// Parse "version" value from given [text] HTML.
  @visibleForTesting
  static String parseVersion(String text) {
    final document = html.parse(text);
    final meta =
        document.querySelector('html > head > meta[name="version"][content]');
    final version = (meta?.attributes["content"]?.trim() ?? '');

    if (version.isEmpty) {
      throw ArgumentError.value(text.substring(0, min(text.length, 50)), "text",
          "Required meta tag is not present.");
    }

    return version;
  }
}
