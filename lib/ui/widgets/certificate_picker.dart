import 'package:eidmsdk/types.dart' show Certificate;
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'certificate_picker_item.dart';

/// Displays [certificates] in a vertical list of [CertificatePickerItem]
/// to pick one.
class CertificatePicker extends StatelessWidget {
  final List<Certificate> certificates;
  final Certificate? selectedCertificate;
  final ValueChanged<Certificate> onCertificateChanged;

  CertificatePicker({
    super.key,
    required this.certificates,
    required this.selectedCertificate,
    required this.onCertificateChanged,
  }) : assert(certificates.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: true,
      children: [
        for (final certificate in certificates) _listItem(certificate),
      ],
    );
  }

  Widget _listItem(Certificate certificate) {
    return CertificatePickerItem(
      key: ObjectKey(certificate),
      certificate: certificate,
      selectedCertificate: selectedCertificate,
      onCertificateChanged: onCertificateChanged,
    );
  }
}

@widgetbook.UseCase(
  path: '[Lists]',
  name: 'AutogramLogo',
  type: CertificatePicker,
)
Widget previewCertificatePicker(BuildContext context) {
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
  const bobCert = """
MIIGJTCCBA2gAwIBAgIBAjANBgkqhkiG9w0BAQUFADCBsjELMAkGA1UEBhMCRlIx
DzANBgNVBAgMBkFsc2FjZTETMBEGA1UEBwwKU3RyYXNib3VyZzEYMBYGA1UECgwP
d3d3LmZyZWVsYW4ub3JnMRAwDgYDVQQLDAdmcmVlbGFuMS0wKwYDVQQDDCRGcmVl
bGFuIFNhbXBsZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkxIjAgBgkqhkiG9w0BCQEW
E2NvbnRhY3RAZnJlZWxhbi5vcmcwHhcNMTIwNDI3MTA1NDQwWhcNMjIwNDI1MTA1
NDQwWjB8MQswCQYDVQQGEwJGUjEPMA0GA1UECAwGQWxzYWNlMRgwFgYDVQQKDA93
d3cuZnJlZWxhbi5vcmcxEDAOBgNVBAsMB2ZyZWVsYW4xDDAKBgNVBAMMA2JvYjEi
MCAGCSqGSIb3DQEJARYTY29udGFjdEBmcmVlbGFuLm9yZzCCAiIwDQYJKoZIhvcN
AQEBBQADggIPADCCAgoCggIBAMI/QxRK1N1DWrlDXi27iaEXGPeuR0t69NTco+G3
hToQIOu8URjYiyXGBJVPgOkFXAD0fCN70a2BWPGdQ8M37n9hA7X/KbsQGvuod5eb
3kx9P8r/U4w3MLaI8g6+fNySdslfIpYZC5HqnBiWn0PRnSKe2cMSn4AFhR9wu4dd
Y8FaUT1+aT12bbBW6ts/rvDNDBlIsfLVLuf6Et0VvIzcCcImnNwiUo7IHMHNAb0a
JMW+TxgI895ZHI9jpmMdT1qSaHpJlCZU0YO+FuRej3MvgTo6MID9V6l/G3vlD2wB
aPcfRUn+BjwIV2QnpQtVGLcwvghFcIvNQ+r8gB4DXMNSjalVU1X0YS6LUGRqMKdv
vbiAEu5mmNh4X6D1ZWpt9QnMYk1VVoAhdUhzTbnj+R2WySxdeU08xXqehP+dx5SH
Cj5pgdJ/wF9nnAaMM1yjn1LnBMfTge+ydx7QVx8fkKVpwA1DxfamfvfqRXxgtmgf
ZFncYDPCE4y3BsIqzcwrAt6i6XAM23n+zutewAbrdkMJ4CrH7h5qr2BJczyoU4zh
OSznnv79RCDwhZof68dAyFuQQ+ahagBQS3NzcsU5dxMePJW+qTdq0U40PTTsh/ge
bOfci3+O0Tx4wuIJk9fAaK5wgbnw0PcmpOLAEh0vAWPrUwXLqttmsPsWm+fnvsNm
2lzJAgMBAAGjezB5MAkGA1UdEwQCMAAwLAYJYIZIAYb4QgENBB8WHU9wZW5TU0wg
R2VuZXJhdGVkIENlcnRpZmljYXRlMB0GA1UdDgQWBBSc0nFQNfcQQ93oznUpo1Nd
EaeoOzAfBgNVHSMEGDAWgBQjbC09PildeLhsPqriuy4ebIfyUzANBgkqhkiG9w0B
AQUFAAOCAgEAw7CkgvVk5U6g5XRexD3QnPdO942viy6AWWO1bi8QW2bWKSrK4gEg
aOEr/9bh4fKm4Mz1j59ccrj6gXZ9XO5gKeXX3o9KnFU+5Sccdrw15xaAbzJ3/Veu
UYf7vsKhzHaaYQHJ/4YA/9GWzf8sD0ieroPY39R4HUw3h/VYXSbGyhbN+hYdb0Ku
V0qZRVKAXBx2Qqj48xWcGz42AeAJXtgZse2g7zvHCaeqX7YtwSCEmyyHGis13p6c
DNkMXs9RONbWgK6RFbXGIt9+F5/D67/91TtL6mYAcqC1t2WoWtmo8WfBQdh53cwv
eHqeXgqddw5ZUknSEJQc6/Q8BA48HBp1pugj1fBzFJCxcVoyV40012ph3HMa2h0f
Vqcu7w2k9fuUC/TPHdIQDwfNup14h+gEY2rlemsgvb0pwjlb/IaEdwvj+Cw3rK8b
7U+51gijrC8xB0r4js8R3ZIcyarHpbdipHduWCB4F8te721B67bCH3+h3vq7cZIg
3rFeNIRs7WzhQ4YT8D/XLcW6wN43jUi838dPs6al5cLb8e/bDCVp5liNunK9Xj/P
gTa2q+6oZ4/uu/5vyR+KH+/pyXpSQK2gPyNFemOVmD0SuOLzC4gQOARosPGni9Bh
1w8vzxdRIet2aS0Z6AHFM/1hzUZkh4lD6THQvoigooIMf59mQTqaWmo=
""";

  const carolCert = """
  MIIGJzCCBA+gAwIBAgIBAzANBgkqhkiG9w0BAQUFADCBsjELMAkGA1UEBhMCRlIx
DzANBgNVBAgMBkFsc2FjZTETMBEGA1UEBwwKU3RyYXNib3VyZzEYMBYGA1UECgwP
d3d3LmZyZWVsYW4ub3JnMRAwDgYDVQQLDAdmcmVlbGFuMS0wKwYDVQQDDCRGcmVl
bGFuIFNhbXBsZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkxIjAgBgkqhkiG9w0BCQEW
E2NvbnRhY3RAZnJlZWxhbi5vcmcwHhcNMTIwNDI3MTA1NDUzWhcNMjIwNDI1MTA1
NDUzWjB+MQswCQYDVQQGEwJGUjEPMA0GA1UECAwGQWxzYWNlMRgwFgYDVQQKDA93
d3cuZnJlZWxhbi5vcmcxEDAOBgNVBAsMB2ZyZWVsYW4xDjAMBgNVBAMMBWNhcm9s
MSIwIAYJKoZIhvcNAQkBFhNjb250YWN0QGZyZWVsYW4ub3JnMIICIjANBgkqhkiG
9w0BAQEFAAOCAg8AMIICCgKCAgEA18CnxulIxFNAs3bZLzcoPaPEQtB2zQibUOMc
UeUUcvoroLEGI/PBrZJ8ef4VVNHlZ2La7YGqfuKxUKn72CkJ2oRNPPRuE6sL1e6A
YzJ9V6+DPBwn7exn1v0cEy1Av9Hav3q2Z36wdTttYZ3MbBqX8Vben4DTFmC7im9G
m740dcNM0vHI8z6YKDDkyy0lYWJIvi7c7ZCTrnS3+klDZSCsjv5SbACOUT62msZP
RBx7hBe9XPY26UyRiW9OrawQQcXFZYogyPcno+qsW3QJmSeIYMdEaRgMMhp38kdT
RuMSxWmVRRWaFGB2IKe1jFG/WlcZWseovAvEMMoL5tD4xKiE2SSikvaE8hPqpJOX
/u132C91eiw5iDxEVgrvElfVno81jn+E5xrRGY0j27XOxX/hiG0E1gHe8HI+UZUd
TzC2MgoPhLUANOS/gHEQYhTBMlqppt7CWOhS62ZauF7CBnymajPyHopBB1O7a0GS
WYV5BKnfVkzgYh6Yh5UHsRBJNJyQTAuDJSefASf70MRuUMz1AkcsRZox5c59ho/b
/YPqpgBJcRREoY6duqSkz50VIC1ndkKBY6J2Tksitd492PjgQ3+jEPBz+27hajeZ
3IejBUwp9WMUm+ujOpsrtFH1BQPeQeXLGo5260eTU5BxxY+GX54LTTOcPIiKkJ+Q
pjWQgfECAwEAAaN7MHkwCQYDVR0TBAIwADAsBglghkgBhvhCAQ0EHxYdT3BlblNT
TCBHZW5lcmF0ZWQgQ2VydGlmaWNhdGUwHQYDVR0OBBYEFLVdDU9V9nUaI7P1jLxr
WraWbK7gMB8GA1UdIwQYMBaAFCNsLT0+KV14uGw+quK7Lh5sh/JTMA0GCSqGSIb3
DQEBBQUAA4ICAQC/P+cWorqxz9Z584TtpRA+YEIO1RrG6bE5hlou3a62txYzMxc+
g/eh97QbCXSPmw2OTMeh1mZsAjq18nKqyeSzxp1uwEjcOSEwGKBvywm+3g9jgwQy
c6e8QjS3odwhIQiGZbwuxXiu+/6r+4uFv2Hg4qpSXx4NGSITlHq0vVwwjUMitOkT
Yn4+9eJ6KjvaH1dKXbhsTPVuNLm9tB/ciNAoIKIMMeh/OiO4YEjITuECYq4A+9Cl
dsvq89d1DZ5WSMEuRMcMnwOzrJbFoqAGnivD67UEFTN5Sp4olB0oUJjj67V0aX9p
vGFy0YrM+4m+UTSBEXv6is/nv4GRNBoRY5JB62J9eipaK6OFNls5CEBrDby37TZC
YEXuDCfxQTie25mPD/8b6gKYnxkhM8qiR4nLHalMlLY9suK/HfcSjQH/d9ZyZXDK
gI6iLXgMsp2EOlD56I6FA1jrCtNb01XQvX3eyFuA6g5T1jWGYBDtvQb0WRVkdUy9
L/uK+sHQwtloCSuakcQAsWV9bajCQtHX8XGu25Yz56kpJ/OJjcishxT6pc/sthum
A5PX739JsNUi/p5aG+H/6eNx+ukJP7QaM646YCfS5i8S9DJUvim+/BSlKi2ZiOCd
0MYH4Xb7lmAOTNmTvSYpKo9J2fZ9erw0MYSBTyjh6F7PRbHBiivgUnJfGQ==
""";

  const certificates = [
    Certificate(
      slot: "1",
      supportedSchemes: [],
      isQualified: true,
      certIndex: 1,
      certData: aliceCert,
    ),
    Certificate(
      slot: "2",
      supportedSchemes: [],
      isQualified: false,
      certIndex: 2,
      certData: bobCert,
    ),
    Certificate(
      slot: "3",
      supportedSchemes: [],
      isQualified: false,
      certIndex: 3,
      certData: carolCert,
    ),
  ];

  Certificate? selectedCertificate;

  return StatefulBuilder(
    builder: (context, setState) {
      return CertificatePicker(
        certificates: certificates,
        selectedCertificate: selectedCertificate,
        onCertificateChanged: (certificate) {
          setState(() => selectedCertificate = certificate);
        },
      );
    },
  );
}
