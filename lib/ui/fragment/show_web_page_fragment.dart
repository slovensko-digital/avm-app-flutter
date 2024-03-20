import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../widgets/loading_indicator.dart';

/// Fragment that displays some web page using [WebViewWidget].
///
/// Params:
///  - [url] - initial URL to load
///  - [onUrlLoaded] - called when that URL was loaded
///  - [onWebResourceError] - called on web resource error
class ShowWebPageFragment extends StatefulWidget {
  final Uri url;
  final VoidCallback? onUrlLoaded;
  final void Function(WebResourceError error)? onWebResourceError;

  const ShowWebPageFragment({
    super.key,
    required this.url,
    this.onUrlLoaded,
    this.onWebResourceError,
  });

  @override
  State<ShowWebPageFragment> createState() => _ShowWebPageFragmentState();
}

class _ShowWebPageFragmentState extends State<ShowWebPageFragment> {
  final WebViewController controller = WebViewController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller.loadRequest(widget.url);
    isLoading = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!kIsWeb) {
      controller.setBackgroundColor(Theme.of(context).colorScheme.background);
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (final String url) {
          if (mounted) {
            setState(() {
              isLoading = true;
            });
          }
        },
        onPageFinished: (final String url) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            if (widget.url.toString() == url) {
              widget.onUrlLoaded?.call();
            }
          }
        },
        onWebResourceError: (error) {
          widget.onWebResourceError?.call(error);
        },
      ));
  }

  @override
  Widget build(BuildContext context) {
    final xState =
        (isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond);

    return AnimatedCrossFade(
      duration: const Duration(microseconds: 150),
      crossFadeState: xState,
      alignment: Alignment.center,
      firstChild: const Center(
        child: LoadingIndicator(),
      ),
      // ignore: deprecated_member_use
      secondChild: WillPopScope(
        // TODO Migrate to PopScope
        // https://docs.flutter.dev/release/breaking-changes/android-predictive-back#migrating-from-willpopscope-to-popscope
        onWillPop: () async {
          if (await controller.canGoBack()) {
            controller.goBack();
            return false;
          } else {
            return true;
          }
        },
        // This SizedBox with arbitrary size fixes issue below:
        // RenderIgnorePointer object was given an infinite size during layout.
        child: SizedBox(
          width: 460,
          height: 1200,
          child: WebViewWidget(controller: controller),
        ),
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Fragments]',
  name: 'ShowWebPageFragment',
  type: ShowWebPageFragment,
)
Widget previewShowWebPageFragment(BuildContext context) {
  final url = Uri.parse("https://www.google.com/");

  return ShowWebPageFragment(
    url: url,
    onUrlLoaded: () {
      developer.log("onUrlLoaded");
    },
    onWebResourceError: (error) {
      developer.log("onWebResourceError", error: error.description);
    },
  );
}
