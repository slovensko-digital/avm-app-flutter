import 'dart:convert';
import 'dart:io';

import 'package:autogram_sign/autogram_sign.dart';
import 'package:eidmsdk/eidmsdk.dart';
import 'package:eidmsdk/eidmsdk_platform_interface.dart';
import 'package:eidmsdk/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../utils.dart' as utils;

// TODO Move to ui/screens, add some docs
class TestPage extends HookWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final eidmsdk = useMemoized(() => Eidmsdk());
    final file = useMemoized(() => XFile.fromData(
          base64Decode(
              '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dGFsb2cvUGFnZXMgNiAwIFIKL09wZW5BY3Rpb25bMSAwIFIgL1hZWiBudWxsIG51bGwgMF0KL0xhbmcoZW4tVVMpCj4+CmVuZG9iagoKMTUgMCBvYmoKPDwvQ3JlYXRvcjxGRUZGMDA1NzAwNzIwMDY5MDA3NDAwNjUwMDcyPgovUHJvZHVjZXI8RkVGRjAwNEMwMDY5MDA2MjAwNzIwMDY1MDA0RjAwNjYwMDY2MDA2OTAwNjMwMDY1MDAyMDAwMzYwMDJFMDAzND4KL0NyZWF0aW9uRGF0ZShEOjIwMjExMTA5MjAzMjUyKzAxJzAwJyk+PgplbmRvYmoKCnhyZWYKMCAxNgowMDAwMDAwMDAwIDY1NTM1IGYgCjAwMDAwMTA1MTMgMDAwMDAgbiAKMDAwMDAwMDAxOSAwMDAwMCBuIAowMDAwMDAwMzE1IDAwMDAwIG4gCjAwMDAwMDAzMzUgMDAwMDAgbiAKMDAwMDAwMjA4MyAwMDAwMCBuIAowMDAwMDEwNjgyIDAwMDAwIG4gCjAwMDAwMDIxMDQgMDAwMDAgbiAKMDAwMDAwOTUyOSAwMDAwMCBuIAowMDAwMDA5NTUwIDAwMDAwIG4gCjAwMDAwMDk3NDUgMDAwMDAgbiAKMDAwMDAxMDEzNSAwMDAwMCBuIAowMDAwMDEwMzgxIDAwMDAwIG4gCjAwMDAwMTA0MTQgMDAwMDAgbiAKMDAwMDAxMDc4MSAwMDAwMCBuIAowMDAwMDEwODc4IDAwMDAwIG4gCnRyYWlsZXIKPDwvU2l6ZSAxNi9Sb290IDE0IDAgUgovSW5mbyAxNSAwIFIKL0lEIFsgPDhGMDUyNjI1QTE1QzdBQkNBODQ2RUY5MDZBQzJGNDc4Pgo8OEYwNTI2MjVBMTVDN0FCQ0E4NDZFRjkwNkFDMkY0Nzg+IF0KL0RvY0NoZWNrc3VtIC9FNTVCMzQ1RUZEQzY5MkFFNTI4OEJFQ0Y5Nzg5NDgxNQo+PgpzdGFydHhyZWYKMTEwNTMKJSVFT0YK'),
          mimeType: 'application/pdf',
        ));
    final fileContent =
        useFuture(useMemoized(() => file.readAsBytes(), [file])).data;

    final localStorage = LocalStorage('document');
    final localStorageReady = useFuture(localStorage.ready);

    final encryptionKey = useState<String?>(utils.createCryptoRandomString());
    final autogram = useMemoized(
        () => AutogramService(
              encryptionKeySource: () => encryptionKey.value ?? '',
            ),
        [encryptionKey.value]);
    final documentId = useState<String?>(null);
    final signingTime = useState<int?>(null);
    final certificates = useState<CertificatesInfo?>(null);
    final dataToSign = useState<String?>(null);
    final signedData = useState<String?>(null);
    final signedDocumentInfo = useState<GetDocumentResponseBody?>(null);

    useEffect(() {
      if (localStorageReady.data == true) {
        final storedValue = localStorage.getItem('certificates');
        if (storedValue.runtimeType == certificates.value.runtimeType) {
          certificates.value = storedValue;
        } else {
          certificates.value = null;
        }
      }
      return null;
    }, [localStorageReady.data]);
    useValueChanged(certificates.value, (oldValue, oldResult) {
      localStorage.setItem('certificates', certificates.value);
      return certificates.value;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Autogram'),
      ),
      body: ListView(
        children: [
          ActionTile(
            title: "Document to sign",
            details: [
              if (fileContent != null)
                SizedBox(
                  height: 300,
                  child: PdfPreview(
                    build: (format) => fileContent,
                  ),
                ),
            ],
            action: ElevatedButton(
              child: const Text('Open'),
              onPressed: () async {
                if (fileContent == null) {
                  return;
                }

                SharePlus.instance.share(ShareParams(
                  files: [
                    XFile.fromData(
                      fileContent,
                      mimeType: file.mimeType,
                      name: file.name.isEmpty ? 'document.pdf' : file.name,
                    ),
                  ],
                ));
              },
            ),
          ),
          ActionTile(
            title: "1. Encryption key",
            details: [Text(encryptionKey.value ?? "<none>")],
            action: ElevatedButton(
              child: const Text('Regenerate'),
              onPressed: () async {
                encryptionKey.value = utils.createCryptoRandomString();
              },
            ),
          ),
          ActionTile(
            title: "2. Document ID",
            details: [Text(documentId.value ?? "<none>")],
            action: ElevatedButton(
              child: const Text('Create'),
              onPressed: () async {
                if (encryptionKey.value == null || fileContent == null) {
                  return;
                }

                final newDocumentId =
                    await autogram.createDocument(DocumentPostRequestBody(
                  document: Document(
                    filename: file.name.isEmpty ? 'document.pdf' : file.name,
                    content: base64Encode(fileContent),
                  ),
                  parameters: const SigningParameters(
                    level: SigningParametersLevel.padesBaselineB,
                    container: null,
                  ),
                  payloadMimeType: "application/pdf;base64",
                ));

                documentId.value = newDocumentId;
              },
            ),
          ),
          ActionTile(
            title: "3. Certificate",
            details: [
              Text(const JsonEncoder.withIndent('  ').convert(
                  Map<String, dynamic>.from(certificates.value?.toJson() ?? {})
                    ..update('certificates', (value) {
                      return List<Map<String, dynamic>>.from(value).map((cert) {
                        return Map<String, dynamic>.from(cert)
                          ..update(
                              'certData',
                              (value) =>
                                  '<... ${base64Decode(value).length} bytes>');
                      }).toList();
                    }, ifAbsent: () => null))),
            ],
            action: Column(
              children: [
                ElevatedButton(
                  child: const Text('Choose'),
                  onPressed: () async {
                    certificates.value = await eidmsdk
                        .getCertificates(types: [EIDCertificateIndex.qes]);
                  },
                ),
                ElevatedButton(
                  child: const Text('Clear'),
                  onPressed: () async {
                    certificates.value = null;
                  },
                ),
              ],
            ),
          ),
          ActionTile(
            title: "4. Data to sign",
            details: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dataToSign.value ?? "<none>"),
                  if (signingTime.value != null)
                    Text(
                        "${DateTime.fromMillisecondsSinceEpoch(signingTime.value!)} (${signingTime.value})")
                  else
                    const Text("<none>"),
                ],
              )
            ],
            action: ElevatedButton(
              child: const Text('Fetch'),
              onPressed: () async {
                if (documentId.value == null || certificates.value == null) {
                  return;
                }
                final result = await autogram.setDataToSign(
                    documentId.value!,
                    DataToSignRequestBody(
                      signingCertificate:
                          certificates.value!.certificates.first.certData,
                    ));
                dataToSign.value = result.dataToSign;
                signingTime.value = result.signingTime;
              },
            ),
          ),
          ActionTile(
            title: "5. Signed data",
            details: [Text(signedData.value ?? "<none>")],
            action: ElevatedButton(
              child: const Text('Sign'),
              onPressed: () async {
                if (certificates.value == null || dataToSign.value == null) {
                  return;
                }

                final certificateIndex =
                    certificates.value!.certificates.firstOrNull?.certIndex;
                if (certificateIndex == null || dataToSign.value == null) {
                  return;
                }

                final result = await eidmsdk.signData(
                  certIndex: certificateIndex,
                  signatureScheme: '1.2.840.113549.1.1.11',
                  dataToSign: dataToSign.value!,
                  isBase64Encoded: true,
                );

                signedData.value = result;
              },
            ),
          ),
          ActionTile(
            title: "6. Submit signed data",
            details: [
              Text(const JsonEncoder.withIndent('  ').convert(
                  Map<String, dynamic>.from(
                      signedDocumentInfo.value?.toJson() ?? {})
                    ..update(
                      'content',
                      (value) =>
                          '<... ${base64Decode(value as String).length} bytes>',
                      ifAbsent: () => null,
                    )))
            ],
            action: ElevatedButton(
              child: const Text('Submit'),
              onPressed: () async {
                if (documentId.value == null ||
                    signedData.value == null ||
                    dataToSign.value == null ||
                    certificates.value == null ||
                    signingTime.value == null) {
                  return;
                }

                await autogram.signDocument(
                  documentId.value!,
                  SignRequestBody(
                      signedData: signedData.value!,
                      dataToSignStructure: DataToSignStructure(
                        dataToSign: dataToSign.value!,
                        signingCertificate:
                            certificates.value!.certificates.first.certData,
                        signingTime: signingTime.value!,
                      )),
                  false,
                );

                signedDocumentInfo.value =
                    await autogram.getDocument(documentId.value!);
              },
            ),
          ),
          ActionTile(
            title: "7. Open signed document",
            details: [
              if (signedDocumentInfo.value != null)
                SizedBox(
                  height: 300,
                  child: PdfPreview(
                    build: (format) =>
                        base64Decode(signedDocumentInfo.value!.content),
                  ),
                ),
            ],
            action: ElevatedButton(
              child: const Text('Open'),
              onPressed: () async {
                if (signedDocumentInfo.value == null) {
                  return;
                }

                final currentDocumentInfo = signedDocumentInfo.value!;

                var documentFile = XFile.fromData(
                  base64Decode(currentDocumentInfo.content),
                  mimeType: currentDocumentInfo.mimeType.value,
                  name: currentDocumentInfo.filename,
                );
                final directory = await getTemporaryDirectory();
                final documentPath =
                    path.join(directory.path, currentDocumentInfo.filename);
                await documentFile.saveTo(documentPath);
                documentFile = XFile(documentPath);
                await SharePlus.instance.share(
                  ShareParams(files: [documentFile]),
                );
                await File(documentFile.path).delete();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ActionTile extends HookWidget {
  final String title;
  final List<Widget> details;
  final Widget action;

  const ActionTile(
      {super.key,
      required this.title,
      this.details = const [],
      required this.action});

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...details,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                action,
              ],
            )
          ],
        ),
      );
}
