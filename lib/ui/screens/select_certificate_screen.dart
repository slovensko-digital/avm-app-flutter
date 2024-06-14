import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/get_document_signature_type_cubit.dart';
import '../../bloc/select_signing_certificate_cubit.dart';
import '../../certificate_extensions.dart';
import '../../data/document_signing_type.dart';
import '../../data/settings.dart';
import '../../data/signature_type.dart';
import '../../di.dart';
import '../../oids.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import '../fragment/select_signing_certificate_fragment.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';
import '../widgets/signature_type_picker.dart';
import 'sign_document_screen.dart';

/// Screen for
///  - loading and presenting [Certificate]
///  - and then selecting the [SignatureType] using [SignatureTypePicker].
///
/// Uses [SelectSigningCertificateCubit] and [GetDocumentSignatureTypeCubit].
///
/// Consumes [ISettings].
///
/// Navigates next to [SignDocumentScreen].
class SelectCertificateScreen extends StatelessWidget {
  final String documentId;
  final DocumentSigningType signingType;

  const SelectCertificateScreen({
    super.key,
    required this.documentId,
    required this.signingType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SelectSigningCertificateCubit>(
      create: (context) {
        final settings = context.read<ISettings>();
        final signingCertificate = settings.signingCertificate;

        return getIt.get<SelectSigningCertificateCubit>(
          param1: signingCertificate,
        )..getCertificates();
      },
      child: BlocBuilder<SelectSigningCertificateCubit,
          SelectSigningCertificateState>(
        builder: (context, state) {
          final showTitle = state is! SelectSigningCertificateLoadingState;

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: showTitle,
              title: showTitle
                  ? Text(context.strings.selectCertificateTitle)
                  : null,
            ),
            body: _Body(
              state: state,
              signingType: signingType,
              documentId: documentId,
              onSignDocumentRequested: (certificate, signatureType) {
                _onSignDocumentRequested(
                  context: context,
                  certificate: certificate,
                  signatureType: signatureType,
                );
              },
              onReloadCertificatesRequested: () {
                _onReloadCertificatesRequested(context);
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _onSignDocumentRequested({
    required BuildContext context,
    required Certificate certificate,
    required SignatureType signatureType,
  }) {
    context.read<ISettings>().signingCertificate.value = certificate;

    final screen = SignDocumentScreen(
      documentId: documentId,
      certificate: certificate,
      signatureType: signatureType,
      signingType: signingType,
    );
    final route = MaterialPageRoute(builder: (_) => screen);

    return Navigator.of(context).push(route);
  }

  Future<void> _onReloadCertificatesRequested(BuildContext context) {
    return context
        .read<SelectSigningCertificateCubit>()
        .getCertificates(refresh: true);
  }
}

/// [SelectCertificateScreen] body.
class _Body extends StatelessWidget {
  final SelectSigningCertificateState state;

  final DocumentSigningType signingType;
  final String documentId;
  final void Function(Certificate certificate, SignatureType signatureType)?
      onSignDocumentRequested;
  final VoidCallback? onReloadCertificatesRequested;

  const _Body({
    required this.state,
    this.signingType = DocumentSigningType.local,
    this.documentId = '',
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
    return SelectSigningCertificateFragment(
      state: state,
      successBuilder: (context, certificate) {
        return _SelectSignatureTypeContent(
          certificate: certificate,
          signingType: signingType,
          documentId: documentId,
          onSignDocumentRequested: (final SignatureType signatureType) {
            onSignDocumentRequested?.call(certificate, signatureType);
          },
          onReloadCertificatesRequested: onReloadCertificatesRequested,
        );
      },
    );
  }
}

/// Success content where [Certificate] was loaded.
/// Only thing is to determine [SignatureType] for given Document, either when:
///  - [DocumentSigningType.local] - from [ISettings.signatureType]
///  - [DocumentSigningType.remote] - by calling [GetDocumentSignatureTypeCubit.getDocumentSignatureType]
///
/// Uses [GetDocumentSignatureTypeCubit].
///
/// Consumes [ISettings].
class _SelectSignatureTypeContent extends StatefulWidget {
  final String? subject;
  final DocumentSigningType signingType;
  final String documentId;
  final ValueSetter<SignatureType>? onSignDocumentRequested;
  final VoidCallback? onReloadCertificatesRequested;

  _SelectSignatureTypeContent({
    required Certificate certificate,
    required this.signingType,
    required this.documentId,
    required this.onSignDocumentRequested,
    required this.onReloadCertificatesRequested,
  }) : subject = certificate.tbsCertificate.subject[X500Oids.cn];

  @override
  State<_SelectSignatureTypeContent> createState() =>
      _SelectSignatureTypeContentState();
}

class _SelectSignatureTypeContentState
    extends State<_SelectSignatureTypeContent> {
  SignatureType? _signatureType;

  @override
  void initState() {
    super.initState();

    if (widget.signingType == DocumentSigningType.local) {
      _signatureType = context.read<ISettings>().signatureType.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final body = BlocProvider<GetDocumentSignatureTypeCubit>(
      create: (context) {
        final cubit = getIt.get<GetDocumentSignatureTypeCubit>();

        switch (widget.signingType) {
          // TODO Refactor this flow; Need to work with Settings in cubit ctor
          // And refactor this widget to be Stateful and work only with Cubit state
          case DocumentSigningType.local:
            cubit.setSignatureType(_signatureType);
            break;

          case DocumentSigningType.remote:
            cubit.getDocumentSignatureType(widget.documentId);
            break;
        }

        return cubit;
      },
      child: BlocConsumer<GetDocumentSignatureTypeCubit,
          GetDocumentSignatureTypeState>(
        listener: (context, state) {
          if (state is GetDocumentSignatureTypeSuccessState) {
            setState(() {
              _signatureType =
                  (state.signatureType ?? SignatureType.withoutTimestamp);
            });
          }
        },
        builder: (context, state) {
          return switch (state) {
            GetDocumentSignatureTypeInitialState _ => const LoadingContent(),
            GetDocumentSignatureTypeLoadingState _ => const LoadingContent(),
            GetDocumentSignatureTypeErrorState state => ErrorContent(
                title: strings.signatureTypeErrorHeading,
                error: state.error,
              ),
            GetDocumentSignatureTypeSuccessState state => SignatureTypePicker(
                value: _signatureType,
                canChange: (widget.signingType == DocumentSigningType.local),
                onValueChanged: (final SignatureType value) {
                  setState(() {
                    _signatureType = value;
                  });
                },
              ),
          };
        },
      ),
    );

    return Column(
      children: [
        Expanded(
          child: body,
        ),

        // Primary button
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed:
              (_signatureType == null || _signatureType == SignatureType.unset
                  ? null
                  : () {
                      widget.onSignDocumentRequested?.call(_signatureType!);
                    }),
          child:
              Text(strings.buttonSignWithCertificateLabel("${widget.subject}")),
          // Extract data
        ),

        const SizedBox(height: kButtonSpace),

        // Secondary button
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: widget.onReloadCertificatesRequested,
          child: Text(strings.buttonSignWithDifferentCertificateLabel),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'loading',
  type: SelectCertificateScreen,
)
Widget previewLoadingSelectCertificateScreen(BuildContext context) {
  return const _Body(
    state: SelectSigningCertificateLoadingState(),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'canceled',
  type: SelectCertificateScreen,
)
Widget previewCanceledSelectCertificateScreen(BuildContext context) {
  return const _Body(
    state: SelectSigningCertificateCanceledState(),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'no certificate',
  type: SelectCertificateScreen,
)
Widget previewNoCertificateSelectCertificateScreen(BuildContext context) {
  return const _Body(
    state: SelectSigningCertificateNoCertificateState(),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'error',
  type: SelectCertificateScreen,
)
Widget previewErrorSelectCertificateScreen(BuildContext context) {
  return const _Body(
    state: SelectSigningCertificateErrorState("Error message!"),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'success',
  type: SelectCertificateScreen,
)
Widget previewSuccessSelectCertificateScreen(BuildContext context) {
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

  return _Body(
    state: const SelectSigningCertificateSuccessState(certificate),
    onReloadCertificatesRequested: () {},
  );
}
