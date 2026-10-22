import 'package:xml/xml.dart';

/// Expanded name - namespace URI (`null` for no namespace) and local name.
class QName {
  final String? namespace;
  final String local;

  const QName(this.namespace, this.local);

  @override
  bool operator ==(Object other) =>
      other is QName && other.namespace == namespace && other.local == local;

  @override
  int get hashCode => Object.hash(namespace, local);

  @override
  String toString() => namespace == null ? local : "{$namespace}$local";
}

const xmlNamespace = "http://www.w3.org/XML/1998/namespace";
const xsltNamespace = "http://www.w3.org/1999/XSL/Transform";

/// Tree of the XPath data model - source document or result tree.
class XTree {
  static int _nextId = 0;

  final int id = _nextId++;
  int _nextOrder = 0;

  int nextOrder() => _nextOrder++;
}

/// Node of the XPath data model.
sealed class XNode {
  final XTree tree;
  XNode? parent;
  int order;

  XNode(this.tree) : order = tree.nextOrder();

  /// String-value of the node.
  String get stringValue;

  /// Compares document order of nodes.
  int compareTo(XNode other) {
    if (tree != other.tree) {
      return tree.id.compareTo(other.tree.id);
    }

    return order.compareTo(other.order);
  }

  XRoot get root {
    XNode node = this;
    while (node.parent != null) {
      node = node.parent!;
    }

    return node as XRoot;
  }
}

/// Node with child nodes - root or element.
sealed class XParent extends XNode {
  final List<XNode> children = [];

  XParent(super.tree);

  String? _stringValue;

  @override
  String get stringValue {
    final cached = _stringValue;
    if (cached != null) return cached;

    final buffer = StringBuffer();
    _writeText(this, buffer);
    return _stringValue = buffer.toString();
  }

  static void _writeText(XParent parent, StringBuffer buffer) {
    for (final child in parent.children) {
      switch (child) {
        case XText text:
          buffer.write(text.value);
        case XElement element:
          _writeText(element, buffer);
        default:
      }
    }
  }

  /// Invalidates cached string value when the tree is being built.
  void invalidate() {
    for (XNode? node = this; node is XParent; node = node.parent) {
      node._stringValue = null;
    }
  }
}

class XRoot extends XParent {
  XRoot(super.tree);
}

class XElement extends XParent {
  final QName name;
  final String? prefix;
  final List<XAttribute> attributes = [];

  /// Namespace declarations of this element (prefix `''` is the default
  /// namespace, empty URI undeclares the default namespace).
  final Map<String, String> declarations;

  XElement(
    super.tree,
    this.name,
    this.prefix, [
    Map<String, String>? declarations,
  ]) : declarations = declarations ?? {};

  /// In-scope namespaces of this element (without the `xml` prefix).
  Map<String, String> get inScopeNamespaces {
    final result = <String, String>{};
    final chain = <XElement>[];
    for (XNode? node = this; node is XElement; node = node.parent) {
      chain.add(node);
    }

    for (final element in chain.reversed) {
      result.addAll(element.declarations);
    }

    result.removeWhere((prefix, uri) => uri.isEmpty);
    return result;
  }

  XAttribute? attribute(QName name) {
    for (final attribute in attributes) {
      if (attribute.name == name) return attribute;
    }

    return null;
  }
}

class XAttribute extends XNode {
  final QName name;
  final String? prefix;
  final String value;

  XAttribute(super.tree, this.name, this.prefix, this.value);

  @override
  String get stringValue => value;
}

class XText extends XNode {
  String value;

  /// Disable output escaping of result tree text.
  final bool disableEscaping;

  XText(super.tree, this.value, {this.disableEscaping = false});

  @override
  String get stringValue => value;
}

class XComment extends XNode {
  final String value;

  XComment(super.tree, this.value);

  @override
  String get stringValue => value;
}

class XProcessingInstruction extends XNode {
  final String target;
  final String value;

  XProcessingInstruction(super.tree, this.target, this.value);

  @override
  String get stringValue => value;
}

/// Namespace node - only for namespace axis.
class XNamespace extends XNode {
  final String prefix;
  final String uri;

  XNamespace(super.tree, this.prefix, this.uri);

  @override
  String get stringValue => uri;
}

/// Builds [XRoot] tree from `package:xml` DOM.
class XTreeBuilder {
  /// Whether whitespace-only text node in element with [name] is stripped.
  final bool Function(QName name)? stripSpace;

  XTreeBuilder({this.stripSpace});

  /// Builds tree with the [element] as the document element.
  ///
  /// Namespace declarations of [element] ancestors are taken into account.
  XRoot buildFromElement(XmlElement element) {
    final tree = XTree();
    final root = XRoot(tree);
    final inherited = <String, String>{};

    final ancestors = <XmlElement>[];
    for (var node = element.parent; node is XmlElement; node = node.parent) {
      ancestors.add(node);
    }
    for (final ancestor in ancestors.reversed) {
      inherited.addAll(_declarations(ancestor));
    }

    _buildElement(tree, root, element, inherited, false);
    return root;
  }

  /// Builds tree from the [document].
  XRoot buildFromDocument(XmlDocument document) {
    final tree = XTree();
    final root = XRoot(tree);
    // whitespace around the document element is not part of the data model
    _buildChildren(
      tree,
      root,
      document.children.where((node) => node is! XmlText && node is! XmlCDATA),
      const {},
      false,
    );
    return root;
  }

  void _buildChildren(
    XTree tree,
    XParent parent,
    Iterable<XmlNode> children,
    Map<String, String> namespaces,
    bool preserveSpace,
  ) {
    XText? lastText;

    for (final child in children) {
      switch (child) {
        case XmlElement element:
          lastText = null;
          _buildElement(tree, parent, element, namespaces, preserveSpace);

        case XmlText() || XmlCDATA():
          final value = child.value ?? "";
          if (lastText != null) {
            lastText.value += value;
          } else {
            final text = XText(tree, value)..parent = parent;
            parent.children.add(text);
            lastText = text;
          }

        case XmlComment comment:
          lastText = null;
          parent.children.add(XComment(tree, comment.value)..parent = parent);

        case XmlProcessing processing:
          lastText = null;
          parent.children.add(
            XProcessingInstruction(tree, processing.target, processing.value)
              ..parent = parent,
          );

        default:
      }
    }

    // strip whitespace-only text nodes
    if (parent is XElement &&
        !preserveSpace &&
        stripSpace != null &&
        stripSpace!(parent.name)) {
      parent.children.removeWhere(
        (node) => node is XText && _isWhitespace(node.value),
      );
    }
    parent.children.removeWhere((node) => node is XText && node.value.isEmpty);
  }

  void _buildElement(
    XTree tree,
    XParent parent,
    XmlElement source,
    Map<String, String> namespaces,
    bool preserveSpace,
  ) {
    final declarations = _declarations(source);
    final scope = declarations.isEmpty
        ? namespaces
        : (Map.of(namespaces)..addAll(declarations));

    final name = _resolve(source.name, scope, isAttribute: false);
    final element = XElement(tree, name, source.name.prefix, declarations)
      ..parent = parent;
    parent.children.add(element);

    for (final attribute in source.attributes) {
      if (_isNamespaceDeclaration(attribute)) continue;

      element.attributes.add(
        XAttribute(
          tree,
          _resolve(attribute.name, scope, isAttribute: true),
          attribute.name.prefix,
          attribute.value,
        )..parent = element,
      );
    }

    final space = _xmlSpace(source);
    final preserve = space == null ? preserveSpace : space == "preserve";

    _buildChildren(tree, element, source.children, scope, preserve);
  }

  static String? _xmlSpace(XmlElement element) {
    for (final attribute in element.attributes) {
      if (attribute.name.prefix == "xml" && attribute.name.local == "space") {
        return attribute.value;
      }
    }

    return null;
  }

  static Map<String, String> _declarations(XmlElement element) {
    final result = <String, String>{};
    for (final attribute in element.attributes) {
      final name = attribute.name;
      if (name.prefix == null && name.local == "xmlns") {
        result[""] = attribute.value;
      } else if (name.prefix == "xmlns") {
        result[name.local] = attribute.value;
      }
    }

    return result;
  }

  static bool _isNamespaceDeclaration(XmlAttribute attribute) {
    final name = attribute.name;
    return (name.prefix == null && name.local == "xmlns") ||
        name.prefix == "xmlns";
  }

  static QName _resolve(
    XmlName name,
    Map<String, String> namespaces, {
    required bool isAttribute,
  }) {
    final prefix = name.prefix;
    if (prefix == null) {
      final uri = isAttribute ? null : namespaces[""];
      return QName(uri == null || uri.isEmpty ? null : uri, name.local);
    }

    if (prefix == "xml") {
      return QName(xmlNamespace, name.local);
    }

    final uri = namespaces[prefix];
    if (uri == null || uri.isEmpty) {
      throw FormatException("Undeclared namespace prefix '$prefix'.");
    }

    return QName(uri, name.local);
  }

  static bool _isWhitespace(String value) => isXmlWhitespace(value);
}

/// Whether the [value] contains only XML whitespace characters.
bool isXmlWhitespace(String value) {
  for (final unit in value.codeUnits) {
    if (unit != 0x20 && unit != 0x09 && unit != 0x0A && unit != 0x0D) {
      return false;
    }
  }

  return true;
}
