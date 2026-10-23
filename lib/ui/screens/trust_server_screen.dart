import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../data/avm_server.dart';
import '../../data/settings.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import '../widgets/result_view.dart';
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

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: kScreenMargin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ResultView(
                  icon: 'assets/images/lock.svg',
                  titleText: strings.trustServerHeading,
                ),
                _ServerCard(server: widget.server),
                const SizedBox(height: 24),
                _InfoRow(
                  icon: Icons.check_circle_outline,
                  iconColor: const Color(0xFF078814),
                  text: strings.trustServerVerifiedInfo,
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.warning_amber_outlined,
                  iconColor: const Color(0xFF9A5B00),
                  text: strings.trustServerNotVerifiedInfo,
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.info_outline,
                  iconColor: Theme.of(context).colorScheme.primary,
                  text: strings.trustServerDocumentTypesInfo,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: _remember,
                  onChanged: (value) {
                    setState(() => _remember = value ?? false);
                  },
                  title: Text(strings.trustServerRememberLabel),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
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

/// Presents the [server] with note, that it's not the official one.
class _ServerCard extends StatelessWidget {
  static const _secondaryColor = Color(0xFF5A4A36);

  final AvmServer server;

  const _ServerCard({required this.server});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF0E2),
        border: Border.all(color: const Color(0xFFEBCFAA)),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            strings.trustServerLabel,
            style: const TextStyle(color: _secondaryColor),
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
            strings.trustServerNotOfficialLabel(AvmServer.official.authority),
            style: const TextStyle(color: _secondaryColor),
          ),
        ],
      ),
    );
  }
}

/// Info [text] with leading [icon].
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Icon(icon, color: iconColor),
        Expanded(child: Text(text)),
      ],
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
