import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/select_certificate_cubit.dart';
import '../../certificate_extensions.dart';
import '../../oids.dart';
import '../app_theme.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';
import '../widgets/retry_view.dart';
import '../widgets/signature_type_picker.dart';
import 'sign_document_screen.dart';

/// Screen for selecting the signature type.
/// Expecting to have at most 1 QES [Certificate].
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
      body: BlocProvider<SelectCertificateCubit>(
        create: (context) {
          return GetIt.instance.get<SelectCertificateCubit>()
            ..getCertificates();
        },
        child: BlocBuilder<SelectCertificateCubit, SelectCertificateState>(
          builder: (context, state) {
            return SelectCertificateBody(
              state: state,
              onSignDocumentRequested: (certificate, addTimeStamp) {
                _onSignDocumentRequested(
                  context: context,
                  certificate: certificate,
                  addTimeStamp: addTimeStamp,
                );
              },
              onReloadCertificatesRequested: () {
                _onReloadCertificatesRequested(context);
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _onSignDocumentRequested({
    required BuildContext context,
    required Certificate certificate,
    required bool addTimeStamp,
  }) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SignDocumentScreen(
        documentId: documentId,
        certificate: certificate,
        addTimeStamp: addTimeStamp,
      ),
    ));
  }

  Future<void> _onReloadCertificatesRequested(BuildContext context) {
    return context.read<SelectCertificateCubit>().getCertificates();
  }
}

class SelectCertificateBody extends StatelessWidget {
  final SelectCertificateState state;
  final void Function(Certificate certificate, bool addTimeStamp)?
      onSignDocumentRequested;
  final VoidCallback? onReloadCertificatesRequested;

  const SelectCertificateBody({
    super.key,
    required this.state,
    this.onSignDocumentRequested,
    this.onReloadCertificatesRequested,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kScreenMargin,
      child: _getChild(context),
    );
  }

  Widget _getChild(BuildContext context) {
    return switch (state) {
      SelectCertificateLoadingState _ => const LoadingContent(),
      SelectCertificateCanceledState _ => RetryView(
          headlineText:
              "Načítavanie certifikátov z\u{00A0}OP\nbolo zrušené používateľom",
          onRetryRequested: () {
            context.read<SelectCertificateCubit>().getCertificates();
          },
        ),
      SelectCertificateNoCertificateState _ => RetryView(
          headlineText:
              "Použitý OP neobsahuje “Kvalifikovaný certifikát pre\u{00A0}elektronický podpis”.\nJe potrebné ho vydať v aplikácii eID Klient, prípadne použiť iný OP.",
          onRetryRequested: () {
            context.read<SelectCertificateCubit>().getCertificates();
          },
        ),
      SelectCertificateErrorState state => ErrorContent(
          title: "Chyba pri načítavaní certifikátov z\u{00A0}OP.",
          error: state.error,
        ),
      SelectCertificateSuccessState state => _SelectSignatureTypeContent(
          certificate: state.certificate,
          onSignDocumentRequested: (final bool addTimeStamp) {
            onSignDocumentRequested?.call(state.certificate, addTimeStamp);
          },
          onReloadCertificatesRequested: onReloadCertificatesRequested,
        ),
      _ => Text("### $state ###"),
    };
  }
}

class _SelectSignatureTypeContent extends StatefulWidget {
  final String? subject;
  final ValueSetter<bool>? onSignDocumentRequested;
  final VoidCallback? onReloadCertificatesRequested;

  _SelectSignatureTypeContent({
    required Certificate certificate,
    required this.onSignDocumentRequested,
    required this.onReloadCertificatesRequested,
  }) : subject = certificate.tbsCertificate.subject[X500Oids.cn];

  @override
  State<_SelectSignatureTypeContent> createState() =>
      _SelectSignatureTypeContentState();
}

class _SelectSignatureTypeContentState
    extends State<_SelectSignatureTypeContent> {
  bool? _addTimeStamp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: SignatureTypePicker(
            value: _addTimeStamp,
            onValueChanged: (final bool value) {
              setState(() {
                _addTimeStamp = value;
              });
            },
          ),
        ),
        Expanded(
          flex: 0,
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: kPrimaryButtonMinimumSize,
            ),
            onPressed: (_addTimeStamp == null
                ? null
                : () {
                    widget.onSignDocumentRequested?.call(_addTimeStamp!);
                  }),
            child: Text("Podpísať ako ${widget.subject}"),
            // Extract data
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 0,
          child: TextButton(
            onPressed: widget.onReloadCertificatesRequested,
            child: const Text("Podpísať iným certifikátom"),
          ),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'loading',
  type: SelectCertificateBody,
)
Widget previewLoadingSelectCertificateBody(BuildContext context) {
  return const SelectCertificateBody(
    state: SelectCertificateLoadingState(),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'canceled',
  type: SelectCertificateBody,
)
Widget previewCanceledSelectCertificateBody(BuildContext context) {
  return const SelectCertificateBody(
    state: SelectCertificateCanceledState(),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'no certificate',
  type: SelectCertificateBody,
)
Widget previewNoCertificateCertificateBody(BuildContext context) {
  return const SelectCertificateBody(
    state: SelectCertificateNoCertificateState(),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'error',
  type: SelectCertificateBody,
)
Widget previewErrorCertificateBody(BuildContext context) {
  return const SelectCertificateBody(
    state: SelectCertificateErrorState("Error message!"),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'success',
  type: SelectCertificateBody,
)
Widget previewSuccessCertificateCertificateBody(BuildContext context) {
  const aliceCert = """
MIIGJzCCBA+gAwIBAgIBATANBgkqhkiG9w0BAQUFADCBsjELMAkGA1UEBhMCRlIx
DzANBgNVBAgMBkFsc2FjZTETMBEGA1UEBwwKU3RyYXNib3VyZzEYMBYGA1UECgwP
d3d3LmZyZWVsYW4ub3JnMRAwDgYDVQQLDAdmcmVlbGFuMS0wKwYDVQQDDCRGcmVl
bGFuIFNhbXBsZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkxIjAgBgkqhkiG9w0BCQEW
E2NvbnRhY3RAZnJlZWxhbi5vcmcwHhcNMTIwNDI3MTAzMTE4WhcNMjIwNDI1MTAz
MTE4WjB+MQswCQYDVQQGEwJGUjEPMA0GA1UECAwGQWxzYWNlMRgwFgYDVQQKDA93
d3cuZnJlZWxhbi5vcmcxEDAOBgNVBAsMB2ZyZWVsYW4xDjAMBgNVBAMMBWFsaWNl
MSIwIAYJKoZIhvcNAQkBFhNjb250YWN0QGZyZWVsYW4ub3JnMIICIjANBgkqhkiG
9w0BAQEFAAOCAg8AMIICCgKCAgEA3W29+ID6194bH6ejLrIC4hb2Ugo8v6ZC+Mrc
k2dNYMNPjcOKABvxxEtBamnSaeU/IY7FC/giN622LEtV/3oDcrua0+yWuVafyxmZ
yTKUb4/GUgafRQPf/eiX9urWurtIK7XgNGFNUjYPq4dSJQPPhwCHE/LKAykWnZBX
RrX0Dq4XyApNku0IpjIjEXH+8ixE12wH8wt7DEvdO7T3N3CfUbaITl1qBX+Nm2Z6
q4Ag/u5rl8NJfXg71ZmXA3XOj7zFvpyapRIZcPmkvZYn7SMCp8dXyXHPdpSiIWL2
uB3KiO4JrUYvt2GzLBUThp+lNSZaZ/Q3yOaAAUkOx+1h08285Pi+P8lO+H2Xic4S
vMq1xtLg2bNoPC5KnbRfuFPuUD2/3dSiiragJ6uYDLOyWJDivKGt/72OVTEPAL9o
6T2pGZrwbQuiFGrGTMZOvWMSpQtNl+tCCXlT4mWqJDRwuMGrI4DnnGzt3IKqNwS4
Qyo9KqjMIPwnXZAmWPm3FOKe4sFwc5fpawKO01JZewDsYTDxVj+cwXwFxbE2yBiF
z2FAHwfopwaH35p3C6lkcgP2k/zgAlnBluzACUI+MKJ/G0gv/uAhj1OHJQ3L6kn1
SpvQ41/ueBjlunExqQSYD7GtZ1Kg8uOcq2r+WISE3Qc9MpQFFkUVllmgWGwYDuN3
Zsez95kCAwEAAaN7MHkwCQYDVR0TBAIwADAsBglghkgBhvhCAQ0EHxYdT3BlblNT
TCBHZW5lcmF0ZWQgQ2VydGlmaWNhdGUwHQYDVR0OBBYEFFlfyRO6G8y5qEFKikl5
ajb2fT7XMB8GA1UdIwQYMBaAFCNsLT0+KV14uGw+quK7Lh5sh/JTMA0GCSqGSIb3
DQEBBQUAA4ICAQAT5wJFPqervbja5+90iKxi1d0QVtVGB+z6aoAMuWK+qgi0vgvr
mu9ot2lvTSCSnRhjeiP0SIdqFMORmBtOCFk/kYDp9M/91b+vS+S9eAlxrNCB5VOf
PqxEPp/wv1rBcE4GBO/c6HcFon3F+oBYCsUQbZDKSSZxhDm3mj7pb67FNbZbJIzJ
70HDsRe2O04oiTx+h6g6pW3cOQMgIAvFgKN5Ex727K4230B0NIdGkzuj4KSML0NM
slSAcXZ41OoSKNjy44BVEZv0ZdxTDrRM4EwJtNyggFzmtTuV02nkUj1bYYYC5f0L
ADr6s0XMyaNk8twlWYlYDZ5uKDpVRVBfiGcq0uJIzIvemhuTrofh8pBQQNkPRDFT
Rq1iTo1Ihhl3/Fl1kXk1WR3jTjNb4jHX7lIoXwpwp767HAPKGhjQ9cFbnHMEtkro
RlJYdtRq5mccDtwT0GFyoJLLBZdHHMHJz0F9H7FNk2tTQQMhK5MVYwg+LIaee586
CQVqfbscp7evlgjLW98H+5zylRHAgoH2G79aHljNKMp9BOuq6SnEglEsiWGVtu2l
hnx8SB3sVJZHeer8f/UQQwqbAO+Kdy70NmbSaqaVtp8jOxLiidWkwSyRTsuU6D8i
DiH5uEqBXExjrj0FslxcVKdVj5glVcSmkLwZKbEU1OKwleT/iXFhvooWhQ==
""";

  const certificate = Certificate(
    slot: "1",
    supportedSchemes: [],
    isQualified: true,
    certIndex: 1,
    certData: aliceCert,
  );

  return const SelectCertificateBody(
    state: SelectCertificateSuccessState(certificate),
  );
}
