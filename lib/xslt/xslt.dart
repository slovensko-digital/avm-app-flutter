/// XSLT 1.0 processor implemented in Dart.
///
/// It is used to visualize XML e-forms on the device, so the visualization
/// doesn't have to be trusted from the server. It supports XSLT 1.0
/// instructions and XPath 1.0 functions (with a few XPath 2.0 string
/// functions), but not external documents (`xsl:import`, `xsl:include`,
/// `document()`).
library;

import 'package:xml/xml.dart';

import 'src/errors.dart';
import 'src/nodes.dart';
import 'src/output.dart';
import 'src/stylesheet.dart';
import 'src/transformer.dart';

export 'src/errors.dart';
export 'src/output.dart' show OutputMethod;

/// Parses XML document with line endings normalized according to XML 1.0
/// section 2.11, which `package:xml` doesn't do.
XmlDocument parseXml(String xml) {
  return XmlDocument.parse(normalizeLineEndings(xml));
}

/// Normalizes literal CRLF and CR line endings to LF.
String normalizeLineEndings(String xml) {
  if (!xml.contains("\r")) return xml;

  return xml.replaceAll("\r\n", "\n").replaceAll("\r", "\n");
}

/// Result of the transformation.
class XsltResult {
  final String content;
  final OutputMethod method;

  const XsltResult(this.content, this.method);
}

/// Compiled XSLT stylesheet.
class XsltProcessor {
  final Stylesheet _stylesheet;

  XsltProcessor._(this._stylesheet);

  /// Compiles stylesheet from its XML source.
  factory XsltProcessor.parse(String stylesheet) {
    final XmlDocument document;
    try {
      document = parseXml(stylesheet);
    } on XmlException catch (e) {
      throw XsltException("Invalid stylesheet XML: ${e.message}");
    }

    return XsltProcessor._(Stylesheet.compile(document.rootElement));
  }

  /// Compiles stylesheet from its root element, e.g. embedded in other XML.
  factory XsltProcessor.fromElement(XmlElement stylesheet) {
    return XsltProcessor._(Stylesheet.compile(stylesheet.copy()));
  }

  /// Transforms document with the [element] as document element.
  XsltResult transformElement(XmlElement element) {
    return _transform(() => _treeBuilder.buildFromElement(element));
  }

  /// Transforms the [document].
  XsltResult transformDocument(XmlDocument document) {
    return _transform(() => _treeBuilder.buildFromDocument(document));
  }

  XTreeBuilder get _treeBuilder => XTreeBuilder(
    stripSpace: _stylesheet.hasSpaceRules ? _stylesheet.stripSpace : null,
  );

  XsltResult _transform(XRoot Function() buildSource) {
    try {
      final result = Transformer(_stylesheet).transform(buildSource());
      final method = _stylesheet.output.effectiveMethod(result);

      return XsltResult(serialize(result, _stylesheet.output), method);
    } on XPathException catch (e) {
      throw XsltException(e.message);
    } on FormatException catch (e) {
      throw XsltException(e.message);
    } on StackOverflowError {
      throw const XsltException("Too deep recursion.");
    }
  }
}
