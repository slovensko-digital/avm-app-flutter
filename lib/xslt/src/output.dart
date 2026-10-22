import 'nodes.dart';

/// Builds result tree (or result tree fragment) of the transformation.
class ResultBuilder {
  final XTree tree = XTree();
  late final XRoot root = XRoot(tree);
  late XParent _current = root;

  /// Whether attributes can be added to the current element.
  var _attributesAllowed = false;

  void startElement(
    QName name,
    String? prefix,
    Map<String, String> namespaces,
  ) {
    final element = XElement(tree, name, prefix, Map.of(namespaces))
      ..parent = _current;
    _current.children.add(element);
    _current.invalidate();
    _current = element;
    _attributesAllowed = true;
  }

  void endElement() {
    _current = _current.parent as XParent;
    _attributesAllowed = false;
  }

  /// Adds attribute to the current element, attributes added after child
  /// nodes are ignored (recoverable error in XSLT 1.0).
  void attribute(QName name, String? prefix, String value) {
    final element = _current;
    if (!_attributesAllowed || element is! XElement) return;

    element.attributes.removeWhere((attribute) => attribute.name == name);
    element.attributes.add(
      XAttribute(tree, name, prefix, value)..parent = element,
    );
  }

  /// Adds namespace declaration to the current element.
  void namespace(String prefix, String uri) {
    final element = _current;
    if (!_attributesAllowed || element is! XElement) return;

    element.declarations.putIfAbsent(prefix, () => uri);
  }

  void text(String value, {bool disableEscaping = false}) {
    if (value.isEmpty) return;
    _attributesAllowed = false;

    final children = _current.children;
    final last = children.isEmpty ? null : children.last;
    if (last is XText && last.disableEscaping == disableEscaping) {
      last.value += value;
    } else {
      children.add(
        XText(tree, value, disableEscaping: disableEscaping)..parent = _current,
      );
    }
    _current.invalidate();
  }

  void comment(String value) {
    _attributesAllowed = false;
    _current.children.add(XComment(tree, value)..parent = _current);
  }

  void processingInstruction(String target, String value) {
    _attributesAllowed = false;
    _current.children.add(
      XProcessingInstruction(tree, target, value)..parent = _current,
    );
  }

  /// Deep copy of the [node] (copy-of).
  void copy(XNode node) {
    switch (node) {
      case XRoot root:
        for (final child in root.children) {
          copy(child);
        }
      case XElement element:
        startElement(element.name, element.prefix, element.inScopeNamespaces);
        for (final attribute in element.attributes) {
          this.attribute(attribute.name, attribute.prefix, attribute.value);
        }
        for (final child in element.children) {
          copy(child);
        }
        endElement();
      case XAttribute attribute:
        this.attribute(attribute.name, attribute.prefix, attribute.value);
      case XText text:
        this.text(text.value, disableEscaping: text.disableEscaping);
      case XComment comment:
        this.comment(comment.value);
      case XProcessingInstruction pi:
        processingInstruction(pi.target, pi.value);
      case XNamespace ns:
        namespace(ns.prefix, ns.uri);
    }
  }
}

enum OutputMethod { xml, html, xhtml, text }

/// Settings of `xsl:output`.
class OutputSettings {
  final OutputMethod? method;
  final bool omitXmlDeclaration;
  final String? doctypePublic;
  final String? doctypeSystem;

  const OutputSettings({
    this.method,
    this.omitXmlDeclaration = false,
    this.doctypePublic,
    this.doctypeSystem,
  });

  /// Output method - explicit or determined from the result tree.
  OutputMethod effectiveMethod(XRoot result) {
    final explicit = method;
    if (explicit != null) return explicit;

    for (final child in result.children) {
      switch (child) {
        case XElement element:
          return element.name.local.toLowerCase() == "html" &&
                  element.name.namespace == null
              ? OutputMethod.html
              : OutputMethod.xml;
        case XText text when text.value.trim().isNotEmpty:
          return OutputMethod.xml;
        default:
      }
    }

    return OutputMethod.xml;
  }
}

/// Serializes result tree according to the output method.
String serialize(XRoot result, OutputSettings settings) {
  final method = settings.effectiveMethod(result);

  return switch (method) {
    OutputMethod.text => result.stringValue,
    OutputMethod.html => _HtmlSerializer(settings).serialize(result),
    OutputMethod.xml || OutputMethod.xhtml => _XmlSerializer(
      settings,
      htmlCompatible: method == OutputMethod.xhtml,
    ).serialize(result),
  };
}

const _voidElements = {
  "area", "base", "basefont", "br", "col", "embed", "frame", "hr", "img", //
  "input", "isindex", "keygen", "link", "meta", "param", "source", "track",
  "wbr",
};

const _booleanAttributes = {
  "checked", "compact", "declare", "defer", "disabled", "ismap", "multiple", //
  "nohref", "noresize", "noshade", "nowrap", "readonly", "selected",
};

const xhtmlNamespace = "http://www.w3.org/1999/xhtml";

class _XmlSerializer {
  final OutputSettings settings;

  /// Never use `<x/>` for elements, which can't be empty in HTML.
  final bool htmlCompatible;

  final _buffer = StringBuffer();

  _XmlSerializer(this.settings, {required this.htmlCompatible});

  String serialize(XRoot root) {
    if (!settings.omitXmlDeclaration) {
      _buffer.write('<?xml version="1.0" encoding="UTF-8"?>');
    }

    final documentElement = root.children.whereType<XElement>().firstOrNull;
    final system = settings.doctypeSystem;
    if (documentElement != null && system != null) {
      final name = _qualifiedName(documentElement.prefix, documentElement.name);
      final public = settings.doctypePublic;
      _buffer.write(
        public != null
            ? '<!DOCTYPE $name PUBLIC "$public" "$system">'
            : '<!DOCTYPE $name SYSTEM "$system">',
      );
    }

    for (final child in root.children) {
      _node(child, const {"xml": xmlNamespace});
    }

    return _buffer.toString();
  }

  void _node(XNode node, Map<String, String> scope) {
    switch (node) {
      case XElement element:
        _element(element, scope);
      case XText text:
        _buffer.write(
          text.disableEscaping ? text.value : escapeText(text.value),
        );
      case XComment comment:
        _buffer.write("<!--${comment.value}-->");
      case XProcessingInstruction pi:
        _buffer.write("<?${pi.target} ${pi.value}?>");
      default:
    }
  }

  void _element(XElement element, Map<String, String> parentScope) {
    final declarations = <String, String>{};
    final scope = Map.of(parentScope);

    void declare(String prefix, String uri) {
      if (scope[prefix] != uri) {
        scope[prefix] = uri;
        declarations[prefix] = uri;
      }
    }

    element.declarations.forEach((prefix, uri) {
      if (prefix != "xml" && (uri.isNotEmpty || scope.containsKey(prefix))) {
        declare(prefix, uri);
      }
    });

    // namespace fixup of element and attribute names
    final elementPrefix = _fixPrefix(
      element.prefix,
      element.name.namespace,
      scope,
      declare,
      isAttribute: false,
    );
    final attributes = <(String, String)>[];
    for (final attribute in element.attributes) {
      final prefix = _fixPrefix(
        attribute.prefix,
        attribute.name.namespace,
        scope,
        declare,
        isAttribute: true,
      );
      attributes.add((_qualifiedName(prefix, attribute.name), attribute.value));
    }

    final name = _qualifiedName(elementPrefix, element.name);
    _buffer.write("<$name");
    declarations.forEach((prefix, uri) {
      _buffer.write(prefix.isEmpty ? ' xmlns="' : ' xmlns:$prefix="');
      _buffer.write(escapeAttribute(uri));
      _buffer.write('"');
    });
    for (final (attributeName, value) in attributes) {
      _buffer.write(' $attributeName="${escapeAttribute(value)}"');
    }

    final isVoid = _voidElements.contains(element.name.local.toLowerCase());
    if (element.children.isEmpty && (!htmlCompatible || isVoid)) {
      _buffer.write(htmlCompatible ? " />" : "/>");
      return;
    }

    _buffer.write(">");

    final isHead = htmlCompatible &&
        element.name.local.toLowerCase() == "head" &&
        (element.name.namespace == null ||
            element.name.namespace == xhtmlNamespace);
    if (isHead) {
      _buffer.write('<meta http-equiv="Content-Type" '
          'content="text/html; charset=UTF-8" />');
    }

    for (final child in element.children) {
      if (isHead && _HtmlSerializer._isContentTypeMeta(child)) continue;
      _node(child, scope);
    }
    _buffer.write("</$name>");
  }

  static String? _fixPrefix(
    String? prefix,
    String? namespace,
    Map<String, String> scope,
    void Function(String prefix, String uri) declare, {
    required bool isAttribute,
  }) {
    if (namespace == null) {
      // unprefixed element in no namespace must not be in default namespace
      if (!isAttribute && (scope[""] ?? "").isNotEmpty) declare("", "");
      return null;
    }

    if (namespace == xmlNamespace) return "xml";

    var candidate = prefix ?? "";
    if (isAttribute && candidate.isEmpty) {
      candidate = _prefixFor(namespace, scope) ?? "ns0";
    }

    if (scope[candidate] == namespace) {
      return candidate.isEmpty ? null : candidate;
    }

    if (scope.containsKey(candidate) && scope[candidate] != namespace) {
      final existing = _prefixFor(namespace, scope);
      if (existing != null && (!isAttribute || existing.isNotEmpty)) {
        return existing.isEmpty ? null : existing;
      }
      if (candidate.isNotEmpty || isAttribute) {
        var i = 0;
        while (scope.containsKey("ns$i")) {
          i++;
        }
        candidate = "ns$i";
      }
    }

    declare(candidate, namespace);
    return candidate.isEmpty ? null : candidate;
  }

  static String? _prefixFor(String namespace, Map<String, String> scope) {
    for (final MapEntry(key: prefix, value: uri) in scope.entries) {
      if (uri == namespace) return prefix;
    }
    return null;
  }
}

class _HtmlSerializer {
  final OutputSettings settings;
  final _buffer = StringBuffer();
  var _doctypeWritten = false;

  _HtmlSerializer(this.settings);

  String serialize(XRoot root) {
    for (final child in root.children) {
      _node(child, false, const {});
    }

    return _buffer.toString();
  }

  /// Writes DOCTYPE just before the first element like Saxon.
  void _writeDoctype(String name) {
    if (_doctypeWritten) return;
    _doctypeWritten = true;

    final public = settings.doctypePublic;
    final system = settings.doctypeSystem;
    if (public == null && system == null) return;

    _buffer.write("<!DOCTYPE $name");
    if (public != null) {
      _buffer.write('\n  PUBLIC "$public"');
      if (system != null) _buffer.write(' "$system"');
    } else {
      _buffer.write('\n  SYSTEM "$system"');
    }
    _buffer.write(">\n");
  }

  void _node(XNode node, bool raw, Map<String, String> scope) {
    switch (node) {
      case XElement element:
        _element(element, scope);
      case XText text:
        _buffer.write(raw || text.disableEscaping
            ? text.value
            : escapeText(text.value));
      case XComment comment:
        _buffer.write("<!--${comment.value}-->");
      case XProcessingInstruction pi:
        _buffer.write("<?${pi.target} ${pi.value}>");
      default:
    }
  }

  void _element(XElement element, Map<String, String> parentScope) {
    final isHtml = element.name.namespace == null ||
        element.name.namespace == xhtmlNamespace;
    final localName = element.name.local;
    final lowerName = localName.toLowerCase();
    final name = element.prefix == null || element.prefix!.isEmpty
        ? localName
        : "${element.prefix}:$localName";

    _writeDoctype(name);

    final scope = Map.of(parentScope);
    _buffer.write("<$name");
    element.declarations.forEach((prefix, uri) {
      if (prefix == "xml" || uri.isEmpty || scope[prefix] == uri) return;
      scope[prefix] = uri;
      _buffer.write(prefix.isEmpty ? ' xmlns="' : ' xmlns:$prefix="');
      _buffer.write(escapeAttribute(uri));
      _buffer.write('"');
    });
    for (final attribute in element.attributes) {
      final attributeName = _qualifiedName(attribute.prefix, attribute.name);
      final value = attribute.value;
      if (isHtml &&
          attribute.name.namespace == null &&
          _booleanAttributes.contains(attributeName.toLowerCase()) &&
          value.toLowerCase() == attributeName.toLowerCase()) {
        _buffer.write(" $attributeName");
      } else {
        _buffer.write(' $attributeName="${_escapeHtmlAttribute(value)}"');
      }
    }
    _buffer.write(">");

    if (isHtml && lowerName == "head") {
      _buffer.write(
          '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">');
    }

    if (isHtml && _voidElements.contains(lowerName)) return;

    final raw = isHtml && (lowerName == "script" || lowerName == "style");
    for (final child in element.children) {
      if (isHtml && lowerName == "head" && _isContentTypeMeta(child)) continue;
      _node(child, raw, scope);
    }
    _buffer.write("</$name>");
  }

  static bool _isContentTypeMeta(XNode node) {
    if (node is! XElement || node.name.local.toLowerCase() != "meta") {
      return false;
    }

    return node.attributes.any((attribute) =>
        attribute.name.local.toLowerCase() == "http-equiv" &&
        attribute.value.toLowerCase() == "content-type");
  }

  static String _escapeHtmlAttribute(String value) {
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final c = value[i];
      switch (c) {
        case "&":
          buffer.write(
              i + 1 < value.length && value[i + 1] == "{" ? "&" : "&amp;");
        case "\"":
          buffer.write("&quot;");
        default:
          buffer.write(c);
      }
    }
    return buffer.toString();
  }
}

String _qualifiedName(String? prefix, QName name) =>
    prefix == null || prefix.isEmpty ? name.local : "$prefix:${name.local}";

String escapeText(String value) {
  if (!value.contains(RegExp(r"[&<>\r]"))) return value;

  return value
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll("\r", "&#xD;");
}

String escapeAttribute(String value) {
  return value
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll("\"", "&quot;")
      .replaceAll("\n", "&#xA;")
      .replaceAll("\r", "&#xD;")
      .replaceAll("\t", "&#x9;");
}
