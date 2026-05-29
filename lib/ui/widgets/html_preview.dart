import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:widgetbook/widgetbook.dart' show KnobsExtension;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Wraps [WebViewWidget] to display HTML directly from [source].
class HtmlPreview extends StatefulWidget {
  final FutureOr<String> source;

  const HtmlPreview({super.key, required this.source});

  @override
  State<HtmlPreview> createState() => _HtmlPreviewState();
}

class _HtmlPreviewState extends State<HtmlPreview> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController();

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

  /// Loads the HTML content from [widget.source] but also disables the
  /// JavaScript before.
  Future<void> _loadHtml() async {
    final html = await widget.source;

    controller.loadHtmlString(html);
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
