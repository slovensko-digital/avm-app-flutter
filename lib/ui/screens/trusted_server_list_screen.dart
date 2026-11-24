import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../data/avm_server.dart';
import '../../data/settings.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import 'trust_server_screen.dart';

/// Displays list of other than official AVM servers, which the user trusts.
/// Documents from them are opened without warning in [TrustServerScreen],
/// until the server is removed.
///
/// Consumes [Settings].
class TrustedServerListScreen extends StatelessWidget {
  const TrustedServerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<Settings>();

    return ValueListenableBuilder(
      valueListenable: settings.trustedServers,
      builder: (context, authorities, _) {
        return _Body(
          servers: [for (final authority in authorities) AvmServer(authority)],
          onDeleteRequested: settings.distrustServer,
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final List<AvmServer> servers;
  final ValueSetter<AvmServer> onDeleteRequested;

  const _Body({required this.servers, required this.onDeleteRequested});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.trustedServersTitle),
      ),
      body: SafeArea(
        child: _getChild(context),
      ),
    );
  }

  Widget _getChild(BuildContext context) {
    final strings = context.strings;

    if (servers.isEmpty) {
      return Center(
        child: Padding(
          padding: kScreenMargin,
          child: Text(
            strings.trustedServersEmpty,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: kScreenMargin,
          child: Text(strings.trustedServersInfo),
        ),
        for (final server in servers)
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: Text(server.authority),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: strings.trustedServerDeleteTooltip,
              onPressed: () => onDeleteRequested(server),
            ),
          ),
      ],
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: '',
  type: TrustedServerListScreen,
)
Widget previewTrustedServerListScreen(BuildContext context) {
  return _Body(
    servers: const [
      AvmServer("avm.example.org"),
      AvmServer("podpis.example.sk:8443"),
    ],
    onDeleteRequested: (server) {
      developer.log('onDeleteRequested: $server');
    },
  );
}
