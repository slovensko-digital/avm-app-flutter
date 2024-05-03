import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../bloc/select_signing_certificate_cubit.dart';
import '../../data/settings.dart';
import '../../strings_context.dart';
import '../app_theme.dart';
import '../fragment/select_signing_certificate_fragment.dart';
import '../widgets/certificate_picker.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/step_indicator.dart';
import 'onboarding_screen.dart';

/// [OnboardingScreen] to select and save signing certificate into
/// [ISettings.signingCertificate].
/// This screen can be skipped.
///
/// Uses [SelectSigningCertificateCubit].
///
/// Consumes [ISettings].
class OnboardingSelectSigningCertificateScreen extends StatelessWidget {
  final VoidCallback onCertificateSelected;
  final VoidCallback? onSkipRequested;

  const OnboardingSelectSigningCertificateScreen({
    super.key,
    required this.onCertificateSelected,
    required this.onSkipRequested,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(context.strings.selectSigningCertificateTitle),
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocProvider<SelectSigningCertificateCubit>(
      create: (context) {
        final settings = context.read<ISettings>();
        final signingCertificate = settings.signingCertificate;

        return GetIt.instance.get<SelectSigningCertificateCubit>(
          param1: signingCertificate,
        );
      },
      child: BlocBuilder<SelectSigningCertificateCubit,
          SelectSigningCertificateState>(
        builder: _buildBodyFromState,
      ),
    );
  }

  Widget _buildBodyFromState(
    BuildContext context,
    SelectSigningCertificateState state,
  ) {
    return _Body(
      state: state,
      onGetCertificatesRequested: () {
        context
            .read<SelectSigningCertificateCubit>()
            .getCertificates(refresh: true);
      },
      onCertificateSelected: (certificate) {
        _handleCertificateSelected(context, certificate);
      },
      onSkipRequested: onSkipRequested,
    );
  }

  void _handleCertificateSelected(
    BuildContext context,
    Certificate certificate,
  ) {
    context.read<ISettings>().signingCertificate.value = certificate;
    onCertificateSelected.call();
  }
}

/// [OnboardingSelectSigningCertificateScreen] body.
class _Body extends StatefulWidget {
  final SelectSigningCertificateState state;
  final VoidCallback? onGetCertificatesRequested;
  final ValueSetter? onCertificateSelected;
  final VoidCallback? onSkipRequested;

  const _Body({
    required this.state,
    this.onGetCertificatesRequested,
    this.onCertificateSelected,
    this.onSkipRequested,
  });

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  Certificate? selectedCertificate;

  @override
  Widget build(BuildContext context) {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SelectSigningCertificateFragment(
            state: widget.state,
            initialBuilder: (context) {
              return Text(
                context.strings.selectSigningCertificateBody,
                textAlign: TextAlign.start,
              );
            },
            successBuilder: (_, certificate) {
              return _SelectCertificate(
                certificate: certificate,
                onCertificateSelected: () {
                  setState(() {
                    selectedCertificate = certificate;
                  });
                },
              );
            },
          ),
        ),

        // Steps
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 16),
          child: StepIndicator(stepNumber: 2, totalSteps: 3),
        ),

        // Primary button
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: _getPrimaryButtonPressedCallback(),
          child: switch (widget.state) {
            SelectSigningCertificateLoadingState _ => const LoadingIndicator(),
            SelectSigningCertificateNoCertificateState _ ||
            SelectSigningCertificateErrorState _ =>
              Text(context.strings.buttonTryAgainLabel),
            _ => Text(context.strings.buttonSelectCertificateLabel),
          },
        ),

        const SizedBox(height: kButtonSpace),

        // Secondary button
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: kPrimaryButtonMinimumSize,
          ),
          onPressed: widget.onSkipRequested,
          child: Text(context.strings.buttonSkipLabel),
        ),
      ],
    );

    return Padding(
      padding: kScreenMargin,
      child: child,
    );
  }

  /// Gets the nullable [VoidCallback] for Primary button.
  VoidCallback? _getPrimaryButtonPressedCallback() {
    final certificate = selectedCertificate;

    return switch (widget.state) {
      SelectSigningCertificateInitialState _ ||
      SelectSigningCertificateCanceledState _ ||
      SelectSigningCertificateErrorState _ ||
      SelectSigningCertificateNoCertificateState _ =>
        widget.onGetCertificatesRequested,
      SelectSigningCertificateSuccessState _ => certificate == null
          ? null
          : () {
              widget.onCertificateSelected?.call(certificate);
            },
      _ => null,
    };
  }
}

/// UI for selecting [Certificate] using [CertificatePicker].
///
/// [onCertificateSelected] is called when user selects the [certificate].
class _SelectCertificate extends StatefulWidget {
  final Certificate certificate;
  final VoidCallback onCertificateSelected;

  const _SelectCertificate({
    required this.certificate,
    required this.onCertificateSelected,
  });

  @override
  State<_SelectCertificate> createState() => _SelectCertificateState();
}

class _SelectCertificateState extends State<_SelectCertificate> {
  Certificate? selectedCertificate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CertificatePicker(
          certificates: [widget.certificate],
          selectedCertificate: selectedCertificate,
          onCertificateChanged: (Certificate certificate) {
            setState(() {
              selectedCertificate = certificate;
            });
            widget.onCertificateSelected();
          },
        ),
        const SizedBox(height: 32),
        const Text(
          "Predvolený podpisový certifikát je možné nastaviť aj počas samotného podpisovania dokumentov.",
        ),
      ],
    );
  }
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'initial',
  type: OnboardingSelectSigningCertificateScreen,
)
Widget previewInitialOnboardingSelectSigningCertificateBody(
    BuildContext context) {
  return const _Body(
    state: SelectSigningCertificateInitialState(),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'canceled',
  type: OnboardingSelectSigningCertificateScreen,
)
Widget previewCanceledOnboardingSelectSigningCertificateBody(
    BuildContext context) {
  return const _Body(
    state: SelectSigningCertificateCanceledState(),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'no certificate',
  type: OnboardingSelectSigningCertificateScreen,
)
Widget previewNoCertificateOnboardingSelectSigningCertificateBody(
    BuildContext context) {
  return const _Body(
    state: SelectSigningCertificateNoCertificateState(),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: 'success',
  type: OnboardingSelectSigningCertificateScreen,
)
Widget previewSuccessOnboardingSelectSigningCertificateBody(
    BuildContext context) {
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

  return const _Body(
    state: SelectSigningCertificateSuccessState(certificate),
  );
}
