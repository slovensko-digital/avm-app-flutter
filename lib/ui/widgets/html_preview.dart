import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:widgetbook/widgetbook.dart' show KnobsExtension;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Wraps [WebViewWidget] to display HTML directly from [source].
///
/// Only the resources embedded in the HTML are loaded and the navigation away
/// from it is prevented, so the displayed content can't be changed by anything
/// outside of the [source].
class HtmlPreview extends StatefulWidget {
  /// Content Security Policy, which allows only inline styles and embedded
  /// images and fonts.
  static const contentSecurityPolicy = "default-src 'none'; "
      "style-src 'unsafe-inline'; img-src data:; font-src data:";

  /// XML declaration and comments followed by DOCTYPE. Comments can't
  /// contain `-->`, so the expression doesn't backtrack exponentially.
  static final _prolog = RegExp(
    r'\s*(<\?xml[^>]*>\s*)?(<!--([^-]|-(?!->))*-->\s*)*<!DOCTYPE[^>]*>',
    caseSensitive: false,
  );

  final FutureOr<String> source;

  const HtmlPreview({super.key, required this.source});

  @override
  State<HtmlPreview> createState() => _HtmlPreviewState();

  /// Adds [contentSecurityPolicy] at the beginning of the [html] - after
  /// DOCTYPE, so it's applied before any resource could be loaded.
  @visibleForTesting
  static String withContentSecurityPolicy(String html) {
    const meta = '<meta http-equiv="Content-Security-Policy" '
        'content="$contentSecurityPolicy">';
    final index = _prolog.matchAsPrefix(html)?.end ?? 0;

    return html.substring(0, index) + meta + html.substring(index);
  }

  /// Allows only loading of the [source], so it can't be replaced by other
  /// page, e.g. via link or `<meta http-equiv="refresh">`.
  static NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final scheme = Uri.tryParse(request.url)?.scheme ?? "";

    return switch (scheme) {
      "" || "about" || "data" => NavigationDecision.navigate,
      _ => NavigationDecision.prevent,
    };
  }
}

class _HtmlPreviewState extends State<HtmlPreview> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController();

    if (!kIsWeb) {
      controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: HtmlPreview._onNavigationRequest,
        ),
      );
    }

    unawaited(_loadHtml());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!kIsWeb) {
      controller.setBackgroundColor(Theme.of(context).colorScheme.surface);
    }
  }

  @override
  void didUpdateWidget(covariant HtmlPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.source != widget.source) {
      unawaited(_loadHtml());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: controller,
    );
  }

  /// Loads the HTML content from [widget.source] with the
  /// [HtmlPreview.contentSecurityPolicy]. JavaScript is disabled by default.
  Future<void> _loadHtml() async {
    final html = await widget.source;

    controller.loadHtmlString(HtmlPreview.withContentSecurityPolicy(html));
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: '',
  type: HtmlPreview,
)
Widget previewHtmlPreview(BuildContext context) {
  final html = context.knobs.string(
    label: 'HTML',
    initialValue: "<html lang=en><h1>Hello world!</h1></html>",
    maxLines: 20,
  );

  return HtmlPreview(
    source: Future.value(html),
  );
}
