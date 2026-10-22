import 'dart:convert' show base64;
import 'dart:typed_data' show Uint8List;

import 'package:xml/xml.dart';

import 'digest_algorithm.dart';
import 'document_verification_exception.dart';
import 'xml_utils.dart';

/// Slovak XML Datacontainer (XDC) with e-form data and references to its XSD
/// and XSLT.
///
/// Digest of the XDC is in the data to sign, so the e-form data and digest of
/// its presentation schema (XSLT) is covered by the signature.
class XmlDataContainer {
  static const mimeType = "application/vnd.gov.sk.xmldatacontainer+xml";

  /// Root element of the e-form data from `xdc:XMLData`.
  final XmlElement formData;

  /// XSLT embedded in `xdc:UsedPresentationSchemaEmbedded`.
  final XmlElement? embeddedTransformation;

  /// Digest of the referenced XSLT from `xdc:UsedPresentationSchemaReference`.
  final ({DigestAlgorithm algorithm, Uint8List value})? transformationDigest;

  /// TXT, HTML or XHTML from the presentation schema.
  final String? mediaDestinationTypeDescription;

  const XmlDataContainer._({
    required this.formData,
    required this.embeddedTransformation,
    required this.transformationDigest,
    required this.mediaDestinationTypeDescription,
  });

  /// Whether the [mimeType] is the one of XML Datacontainer.
  static bool isXmlDataContainerMimeType(String mimeType) {
    return mimeType.trim().toLowerCase().startsWith(XmlDataContainer.mimeType);
  }

  /// Parses UTF-8 encoded XML Datacontainer.
  factory XmlDataContainer.parse(Uint8List data) {
    final root = parseXmlDocument(data, "XML Datacontainer").rootElement;
    if (!isElement(root, XmlNamespaces.xmlDataContainer, "XMLDataContainer")) {
      throw const DocumentVerificationException(
        DocumentVerificationFailure.unsupportedData,
        "Expected xdc:XMLDataContainer.",
      );
    }

    final xmlData = singleChildElement(
      root,
      XmlNamespaces.xmlDataContainer,
      "XMLData",
    );
    if (xmlData.childElements.length != 1) {
      throw const DocumentVerificationException(
        DocumentVerificationFailure.unsupportedData,
        "Expected single e-form element in xdc:XMLData.",
      );
    }

    XmlElement? presentationSchema;
    XmlElement? embeddedTransformation;
    ({DigestAlgorithm algorithm, Uint8List value})? transformationDigest;

    final embedded = _descendants(root, "UsedPresentationSchemaEmbedded");
    final referenced = _descendants(root, "UsedPresentationSchemaReference");
    if (embedded.length + referenced.length > 1) {
      throw const DocumentVerificationException(
        DocumentVerificationFailure.unsupportedData,
        "Multiple presentation schemas in XML Datacontainer.",
      );
    }

    if (embedded.isNotEmpty) {
      presentationSchema = embedded.single;
      embeddedTransformation = presentationSchema.childElements.singleOrNull;
    } else if (referenced.isNotEmpty) {
      presentationSchema = referenced.single;

      final Uint8List value;
      try {
        value = base64.decode(
          presentationSchema.getAttribute("DigestValue") ?? "",
        );
      } on FormatException {
        throw const DocumentVerificationException(
          DocumentVerificationFailure.unsupportedData,
          "Invalid digest of presentation schema.",
        );
      }

      transformationDigest = (
        algorithm: DigestAlgorithm.fromOidUrn(
          presentationSchema.getAttribute("DigestMethod"),
        ),
        value: value,
      );
    }

    return XmlDataContainer._(
      formData: xmlData.childElements.single,
      embeddedTransformation: embeddedTransformation,
      transformationDigest: transformationDigest,
      mediaDestinationTypeDescription: presentationSchema?.getAttribute(
        "MediaDestinationTypeDescription",
      ),
    );
  }

  /// Verifies that the [transformation] is the XSLT referenced from this
  /// XML Datacontainer.
  ///
  /// The [transformation] must be canonicalized by the `TransformAlgorithm`
  /// of the reference, as the digest is computed from canonical XML.
  void verifyTransformation(Uint8List transformation) {
    final digest = transformationDigest;
    if (digest == null) {
      throw const DocumentVerificationException(
        DocumentVerificationFailure.transformationMismatch,
        "XML Datacontainer doesn't reference any presentation schema.",
      );
    }

    final actual = digest.algorithm.digest([transformation]);
    if (!_equals(actual, digest.value)) {
      throw const DocumentVerificationException(
        DocumentVerificationFailure.transformationMismatch,
        "XSLT doesn't match the digest in XML Datacontainer.",
      );
    }
  }

  /// Whether the [formData] is the same e-form as the root element of the
  /// [xml] document - XML Datacontainer is created by the server from it.
  bool containsForm(Uint8List xml) {
    var data = xml;
    // UTF-8 BOM
    if (data.length >= 3 &&
        data[0] == 0xEF &&
        data[1] == 0xBB &&
        data[2] == 0xBF) {
      data = data.sublist(3);
    }

    try {
      return _sameElement(formData, parseXmlDocument(data, "XML").rootElement);
    } on DocumentVerificationException {
      return false;
    }
  }

  static List<XmlElement> _descendants(XmlElement root, String localName) {
    return root.descendantElements
        .where(
          (element) =>
              isElement(element, XmlNamespaces.xmlDataContainer, localName),
        )
        .toList();
  }

  static bool _sameElement(XmlElement a, XmlElement b) {
    if (a.name.local != b.name.local ||
        elementNamespace(a) != elementNamespace(b)) {
      return false;
    }

    final attributesA = _attributes(a), attributesB = _attributes(b);
    if (attributesA.length != attributesB.length ||
        attributesA.entries.any((e) => attributesB[e.key] != e.value)) {
      return false;
    }

    final childrenA = _children(a), childrenB = _children(b);
    if (childrenA.length != childrenB.length) {
      return false;
    }

    for (var i = 0; i < childrenA.length; i++) {
      final childA = childrenA[i], childB = childrenB[i];

      if (childA is XmlElement && childB is XmlElement) {
        if (!_sameElement(childA, childB)) return false;
      } else if (childA is String && childB is String) {
        if (childA != childB) return false;
      } else {
        return false;
      }
    }

    return true;
  }

  /// Gets attributes except of namespace declarations keyed by namespace and
  /// local name.
  static Map<String, String> _attributes(XmlElement element) {
    return {
      for (final attribute in element.attributes)
        if (attribute.name.prefix != "xmlns" &&
            attribute.name.qualified != "xmlns")
          "${attribute.name.prefix == null ? "" : namespaceForPrefix(element, attribute.name.prefix)} ${attribute.name.local}":
              attribute.value,
    };
  }

  /// Gets child elements and texts (adjacent text and CDATA nodes merged).
  static List<Object> _children(XmlElement element) {
    final children = <Object>[];
    final text = StringBuffer();

    for (final child in element.children) {
      if (child is XmlText || child is XmlCDATA) {
        text.write(child.value);
      } else if (child is XmlElement) {
        if (text.isNotEmpty) {
          children.add(text.toString());
          text.clear();
        }
        children.add(child);
      }
    }

    if (text.isNotEmpty) {
      children.add(text.toString());
    }

    return children;
  }

  static bool _equals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }
}
