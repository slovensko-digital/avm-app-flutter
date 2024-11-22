import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Wraps [WebViewWidget] to display HTML directly from [htmlDataSource].
class HtmlPreview extends StatefulWidget {
  final FutureOr<String> htmlDataSource;

  const HtmlPreview({super.key, required this.htmlDataSource});

  @override
  State<HtmlPreview> createState() => _HtmlPreviewState();
}

class _HtmlPreviewState extends State<HtmlPreview> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController();

    Future.value(widget.htmlDataSource).then(controller.loadHtmlString);
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

    if (oldWidget.htmlDataSource != widget.htmlDataSource) {
      Future.value(widget.htmlDataSource).then(controller.loadHtmlString);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: controller,
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: 'HtmlPreview',
  type: HtmlPreview,
)
Widget previewHtmlPreview(BuildContext context) {
  return HtmlPreview(
    htmlDataSource: Future.value("<html lang=en><h1>Hello world!</h1></html>"),
  );
}
