import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../data/avm_server.dart';
import '../../data/settings.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import 'preview_document_screen.dart';
import 'trusted_server_list_screen.dart';

/// Warns the user, that the document is from other than the official
/// [server], before showing the [next] screen with the document.
///
/// The user can trust the [server] also next time, so this screen is not shown
/// for its documents - see [TrustedServersSettings].
///
/// See also:
///  - [PreviewDocumentScreen]
///  - [TrustedServerListScreen]
class TrustServerScreen extends StatelessWidget {
  final AvmServer server;
  final Widget next;

  const TrustServerScreen({
    super.key,
    required this.server,
    required this.next,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.trustServerTitle),
      ),
      body: SafeArea(
        child: _Body(
          server: server,
          onContinueRequested: (remember) {
            _onContinueRequested(context, remember);
          },
          onCancelRequested: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }

  Future<void> _onContinueRequested(BuildContext context, bool remember) {
    if (remember) {
      context.read<Settings>().trustServer(server);
    }

    final route = MaterialPageRoute(builder: (_) => next);

    return Navigator.of(context).pushReplacement(route);
  }
}

/// [TrustServerScreen] body.
class _Body extends StatefulWidget {
  final AvmServer server;
  final ValueSetter<bool> onContinueRequested;
  final VoidCallback onCancelRequested;

  const _Body({
    required this.server,
    required this.onContinueRequested,
    required this.onCancelRequested,
  });

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  bool _remember = false;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: kScreenMargin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    strings.trustServerHeading,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _ServerWarning(server: widget.server),
                const SizedBox(height: 20),
                Text(
                  "${strings.trustServerVerifiedInfo} "
                  "${strings.trustServerNotVerifiedInfo}",
                ),
                const SizedBox(height: 12),
                Text(
                  strings.trustServerDocumentTypesInfo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _remember,
                  onChanged: (value) {
                    setState(() => _remember = value ?? false);
                  },
                  title: Text(strings.trustServerRememberLabel),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  // ID-SK checkbox - big box with border and check mark
                  checkboxScaleFactor: kRadioScale,
                  checkboxShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  side: WidgetStateBorderSide.resolveWith(
                    (_) => BorderSide(color: onSurface, width: 2),
                  ),
                  fillColor: const WidgetStatePropertyAll(Colors.transparent),
                  checkColor: onSurface,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: kScreenMargin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: kPrimaryButtonMinimumSize,
                ),
                onPressed: () => widget.onContinueRequested(_remember),
                child: Text(strings.buttonContinueLabel),
              ),
              const SizedBox(height: kButtonSpace),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: kPrimaryButtonMinimumSize,
                ),
                onPressed: widget.onCancelRequested,
                child: Text(strings.buttonCancelLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Warning about the [server], that it's not the official one; styled as
/// ID-SK warning with its yellow colors.
class _ServerWarning extends StatelessWidget {
  static const _lightYellow = Color(0xFFFAF4EC);
  static const _mediumYellow = Color(0xFFEBCFAA);
  static const _yellow = Color(0xFFBD730C);
  static const _darkYellow = Color(0xFF4E2A00);

  final AvmServer server;

  const _ServerWarning({required this.server});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lightYellow,
        border: Border.all(color: _mediumYellow),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          const Icon(Icons.warning, color: _yellow),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  strings.trustServerLabel,
                  style: const TextStyle(color: _darkYellow),
                ),
                Text(
                  server.authority,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  strings.trustServerNotOfficialLabel(
                    AvmServer.official.authority,
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _darkYellow,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: '',
  type: TrustServerScreen,
)
Widget previewTrustServerScreen(BuildContext context) {
  return Scaffold(
    body: _Body(
      server: const AvmServer("avm.example.org"),
      onContinueRequested: (remember) {
        developer.log('onContinueRequested: $remember');
      },
      onCancelRequested: () {
        developer.log('onCancelRequested');
      },
    ),
  );
}
