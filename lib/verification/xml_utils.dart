import 'dart:convert' show utf8;

import 'package:xml/xml.dart';

import 'document_verification_exception.dart';

/// XML namespace URIs.
abstract class XmlNamespaces {
  static const xmlDsig = "http://www.w3.org/2000/09/xmldsig#";
  static const asic = "http://uri.etsi.org/02918/v1.2.1#";
  static const xmlDataContainer =
      "http://data.gov.sk/def/container/xmldatacontainer+xml/1.1";
  static const xml = "http://www.w3.org/XML/1998/namespace";
}

/// Parses XML document from UTF-8 encoded [data].
///
/// Documents with DTD are refused, because DTD can change their content.
XmlDocument parseXmlDocument(List<int> data, String what) {
  final XmlDocument document;

  try {
    // line endings normalized according to XML 1.0 section 2.11
    final xml = utf8
        .decode(data)
        .replaceAll("\r\n", "\n")
        .replaceAll("\r", "\n");
    document = XmlDocument.parse(xml);
  } on Exception catch (error) {
    throw DocumentVerificationException(
      DocumentVerificationFailure.unsupportedData,
      "Unable to parse $what: $error",
    );
  }

  if (document.children.any((node) => node is XmlDoctype)) {
    throw DocumentVerificationException(
      DocumentVerificationFailure.unsupportedData,
      "DTD is not allowed in $what.",
    );
  }

  return document;
}

/// Gets namespace URI of the [element] according to XML Namespaces.
String? elementNamespace(XmlElement element) {
  return namespaceForPrefix(element, element.name.prefix);
}

/// Gets namespace URI bound to the [prefix] in scope of the [node]. `null`
/// [prefix] means the default namespace.
String? namespaceForPrefix(XmlNode node, String? prefix) {
  if (prefix == "xml") {
    return XmlNamespaces.xml;
  }

  for (XmlNode? current = node; current != null; current = current.parent) {
    for (final attribute in current.attributes) {
      final name = attribute.name;
      if (prefix == null
          ? (name.prefix == null && name.local == "xmlns")
          : (name.prefix == "xmlns" && name.local == prefix)) {
        return attribute.value.isEmpty ? null : attribute.value;
      }
    }
  }

  return null;
}

/// Whether the [element] has given [namespace] and [localName].
bool isElement(XmlElement element, String namespace, String localName) {
  return element.name.local == localName &&
      elementNamespace(element) == namespace;
}

/// Gets child elements of [parent] with given [namespace] and [localName].
Iterable<XmlElement> childElements(
  XmlNode parent,
  String namespace,
  String localName,
) {
  return parent.childElements.where(
    (element) => isElement(element, namespace, localName),
  );
}

/// Gets the only child element of [parent] with given [namespace] and
/// [localName].
XmlElement singleChildElement(
  XmlNode parent,
  String namespace,
  String localName,
) {
  final elements = childElements(parent, namespace, localName).toList();
  if (elements.length != 1) {
    throw DocumentVerificationException(
      DocumentVerificationFailure.unsupportedData,
      "Expected single $localName element, found ${elements.length}.",
    );
  }

  return elements.single;
}

/// Decodes `%XX` escapes in the URI reference of a data object.
String decodeUriReference(String uri) {
  try {
    return Uri.decodeComponent(uri);
  } catch (_) {
    return uri;
  }
}
