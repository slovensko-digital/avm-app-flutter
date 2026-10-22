import 'dart:convert' show base64;
import 'dart:typed_data' show Uint8List;

import 'package:xml/xml.dart';

import 'digest_algorithm.dart';
import 'document_verification_exception.dart';
import 'xml_utils.dart';

/// Reference to a signed data object along with its digest.
class DataObjectReference {
  static const _signedPropertiesType =
      "http://uri.etsi.org/01903#SignedProperties";

  /// Decoded URI of the data object - its filename in ASiC container.
  final String uri;
  final DigestAlgorithm digestAlgorithm;
  final Uint8List digestValue;

  const DataObjectReference(this.uri, this.digestAlgorithm, this.digestValue);

  /// Parses the only data object reference from XAdES `ds:SignedInfo`, which
  /// is the data to sign of XAdES signature in ASiC container.
  ///
  /// Besides the data object, `ds:SignedInfo` may reference only the
  /// `xades:SignedProperties` of the signature itself.
  factory DataObjectReference.fromSignedInfo(Uint8List signedInfo) {
    final root = parseXmlDocument(signedInfo, "SignedInfo").rootElement;
    if (!isElement(root, XmlNamespaces.xmlDsig, "SignedInfo")) {
      throw _unsupported("expected ds:SignedInfo");
    }

    final references = childElements(
      root,
      XmlNamespaces.xmlDsig,
      "Reference",
    ).toList();
    final signedProperties = references.where(
      (reference) =>
          reference.getAttribute("Type") == _signedPropertiesType &&
          (reference.getAttribute("URI") ?? "").startsWith("#"),
    );
    final dataObjects = references.where(
      (reference) =>
          reference.getAttribute("Type") == null &&
          !(reference.getAttribute("URI") ?? "#").startsWith("#"),
    );

    if (references.length != 2 ||
        signedProperties.length != 1 ||
        dataObjects.length != 1) {
      throw _unsupported(
        "expected references to single data object and signed properties",
      );
    }

    final dataObject = dataObjects.single;
    if (childElements(
      dataObject,
      XmlNamespaces.xmlDsig,
      "Transforms",
    ).isNotEmpty) {
      throw _unsupported("transforms of data object are not supported");
    }

    return _fromElement(dataObject);
  }

  /// Parses the only data object reference from `asic:ASiCManifest`, which is
  /// signed by CAdES signature in ASiC-E container.
  factory DataObjectReference.fromAsicManifest(Uint8List manifest) {
    final root = parseXmlDocument(manifest, "ASiC manifest").rootElement;
    if (!isElement(root, XmlNamespaces.asic, "ASiCManifest")) {
      throw _unsupported("expected asic:ASiCManifest");
    }

    return _fromElement(
      singleChildElement(root, XmlNamespaces.asic, "DataObjectReference"),
    );
  }

  static DataObjectReference _fromElement(XmlElement reference) {
    final digestMethod = singleChildElement(
      reference,
      XmlNamespaces.xmlDsig,
      "DigestMethod",
    );
    final digestValue = singleChildElement(
      reference,
      XmlNamespaces.xmlDsig,
      "DigestValue",
    );

    final Uint8List value;
    try {
      value = base64.decode(digestValue.innerText.replaceAll(_whitespace, ""));
    } on FormatException {
      throw _unsupported("invalid DigestValue");
    }

    return DataObjectReference(
      decodeUriReference(reference.getAttribute("URI") ?? ""),
      DigestAlgorithm.fromXmlDsigUri(digestMethod.getAttribute("Algorithm")),
      value,
    );
  }

  static final _whitespace = RegExp(r"\s");

  static DocumentVerificationException _unsupported(String message) {
    return DocumentVerificationException(
      DocumentVerificationFailure.unsupportedData,
      "Unsupported data object reference: $message.",
    );
  }
}
