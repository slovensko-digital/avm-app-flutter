import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../bloc/select_certificate_cubit.dart';
import '../../certificate_extensions.dart';
import '../../oids.dart';
import '../widgets/certificate_picker.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';
import '../widgets/retry_view.dart';
import 'sign_document_screen.dart';

/// Screen for selecting the [Certificate].
///
/// Uses [SelectCertificateCubit].
class SelectCertificateScreen extends StatelessWidget {
  final String documentId;

  const SelectCertificateScreen({
    super.key,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Výber typu podpisu"),
      ),
      body: _Body(documentId: documentId),
    );
  }
}

class _Body extends StatelessWidget {
  final String documentId;

  const _Body({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SelectCertificateCubit>(
      create: (context) {
        return GetIt.instance.get<SelectCertificateCubit>()..getCertificates();
      },
      child: BlocBuilder<SelectCertificateCubit, SelectCertificateState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: _getChild(context, state),
          );
        },
      ),
    );
  }

  Widget _getChild(BuildContext context, SelectCertificateState state) {
    return switch (state) {
      SelectCertificateLoadingState _ => const LoadingContent(),
      SelectCertificateCanceledState _ => RetryView(
          headlineText:
              "Načítavanie certifikátov z\u{00A0}OP\nbolo zrušené používateľom",
          onRetryRequested: () {
            context.read<SelectCertificateCubit>().getCertificates();
          },
        ),
      SelectCertificateErrorState state => ErrorContent(
          title: "Chyba pri načítavaní certifikátov z\u{00A0}OP.",
          error: state.error,
        ),
      SelectCertificateSuccessState state => _CertificateListContent(
          certificates: state.certificates.certificates,
          onSignDocumentRequested: (certificate) {
            _onSignDocumentRequested(context, certificate);
          },
        ),
      _ => Text("### $state ###"),
    };
  }

  Future<void> _onSignDocumentRequested(
    BuildContext context,
    Certificate certificate,
  ) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SignDocumentScreen(
        documentId: documentId,
        certificate: certificate,
      ),
    ));
  }
}

class _CertificateListContent extends StatefulWidget {
  final List<Certificate> certificates;
  final ValueSetter<Certificate>? onSignDocumentRequested;

  const _CertificateListContent({
    required this.certificates,
    required this.onSignDocumentRequested,
  });

  @override
  State<_CertificateListContent> createState() =>
      _CertificateListContentState();
}

class _CertificateListContentState extends State<_CertificateListContent> {
  Certificate? _selectedCertificate;

  String? get _selectedCertificateSubject {
    final cert = _selectedCertificate;

    return cert?.tbsCertificate.subject[X500Oids.cn];
  }

  @override
  void initState() {
    super.initState();

    _selectedCertificate = widget.certificates.singleOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final certificates = widget.certificates;

    return Column(
      children: [
        if (certificates.isNotEmpty)
          Expanded(
            flex: 1,
            // TODO Pass structure with boolean whether to USE timestamping
            child: CertificatePicker(
              certificates: certificates,
              selectedCertificate: _selectedCertificate,
              onCertificateChanged: (certificate) {
                setState(() {
                  _selectedCertificate = certificate;
                });
              },
            ),
          ),
        Expanded(
          flex: 0,
          child: FilledButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(kMinInteractiveDimension),
            ),
            onPressed: (_selectedCertificate == null
                ? null
                : () {
                    _onUseCertificate(_selectedCertificate!);
                  }),
            child: Text(_selectedCertificate == null
                ? "Podpísať"
                : "Podpísať ako $_selectedCertificateSubject"),
            // Extract data
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 0,
          child: TextButton(
            onPressed: _onReloadCertificatesRequested,
            child: const Text("Podpísať iným certifikátom"),
          ),
        ),
      ],
    );
  }

  void _onUseCertificate(Certificate certificate) {
    widget.onSignDocumentRequested?.call(certificate);
  }

  Future<void> _onReloadCertificatesRequested() {
    return context.read<SelectCertificateCubit>().getCertificates();
  }
}
