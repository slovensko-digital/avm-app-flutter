import 'package:xml/xml.dart';

import 'avt.dart';
import 'errors.dart';
import 'format_number.dart';
import 'instructions.dart';
import 'nodes.dart';
import 'output.dart';
import 'patterns.dart';
import 'xpath/ast.dart';
import 'xpath/parser.dart';

/// Template rule - single alternative of `match` pattern.
class TemplateRule {
  final PathPattern pattern;
  final double priority;

  /// Position of the template in the stylesheet, later wins in conflicts.
  final int position;
  final Template template;

  const TemplateRule(this.pattern, this.priority, this.position, this.template);
}

class Template {
  final QName? name;
  final QName? mode;
  final List<ParamInstruction> parameters;
  final List<Instruction> body;

  const Template(this.name, this.mode, this.parameters, this.body);
}

/// Global variable or parameter.
class GlobalVariable {
  final QName name;
  final Expression? select;
  final List<Instruction> body;

  const GlobalVariable(this.name, this.select, this.body);
}

class KeyDefinition {
  final Pattern match;
  final Expression use;

  const KeyDefinition(this.match, this.use);
}

/// Name test of `xsl:strip-space` or `xsl:preserve-space`.
class _SpaceRule {
  final String? namespace;
  final bool anyNamespace;
  final String? local;
  final bool strip;
  final double priority;

  const _SpaceRule(
    this.namespace,
    this.local,
    this.strip, {
    this.anyNamespace = false,
    required this.priority,
  });

  bool matches(QName name) =>
      (anyNamespace || namespace == name.namespace) &&
      (local == null || local == name.local);
}

/// Compiled XSLT stylesheet.
class Stylesheet {
  final double version;
  final OutputSettings output;
  final Map<QName?, List<TemplateRule>> _rulesByMode = {};
  final Map<QName, Template> namedTemplates = {};
  final Map<QName, GlobalVariable> globals = {};
  final Map<QName, List<KeyDefinition>> keys = {};
  final Map<QName?, DecimalFormat> decimalFormats = {};
  final Map<QName, List<Instruction>> attributeSets = {};
  final List<_SpaceRule> _spaceRules = [];

  Stylesheet._(this.version, this.output);

  /// Compiles stylesheet from its root [element] (`xsl:stylesheet` or
  /// `xsl:transform`).
  factory Stylesheet.compile(XmlElement element) =>
      _StylesheetCompiler().compile(element);

  /// Whether whitespace-only text nodes of element [name] are stripped from
  /// the source document.
  bool stripSpace(QName name) {
    _SpaceRule? best;
    for (final rule in _spaceRules) {
      if (rule.matches(name) &&
          (best == null || rule.priority >= best.priority)) {
        best = rule;
      }
    }
    return best?.strip ?? false;
  }

  bool get hasSpaceRules => _spaceRules.isNotEmpty;

  /// Finds the best template rule for the [node] in the [mode].
  TemplateRule? findRule(XNode node, QName? mode, XPathContext context) {
    final rules = _rulesByMode[mode];
    if (rules == null) return null;

    for (final rule in rules) {
      if (rule.pattern.matches(node, context)) return rule;
    }

    return null;
  }

  void _addRule(QName? mode, TemplateRule rule) {
    _rulesByMode.putIfAbsent(mode, () => []).add(rule);
  }

  void _sortRules() {
    for (final rules in _rulesByMode.values) {
      rules.sort((a, b) {
        final priority = b.priority.compareTo(a.priority);
        return priority != 0 ? priority : b.position.compareTo(a.position);
      });
    }
  }
}

class _StylesheetCompiler {
  late Stylesheet _stylesheet;
  var _position = 0;

  /// Prefixes excluded from literal result elements.
  final _excludedNamespaces = <String>{xsltNamespace};
  String? _xpathDefaultNamespace;

  Stylesheet compile(XmlElement root) {
    if (_namespaceOf(root) != xsltNamespace ||
        (root.name.local != "stylesheet" && root.name.local != "transform")) {
      throw const XsltException("Expected xsl:stylesheet root element.");
    }

    _stripWhitespace(root, false);

    final version = double.tryParse(root.getAttribute("version") ?? "") ?? 1.0;
    _xpathDefaultNamespace = root.getAttribute("xpath-default-namespace");
    _excludedNamespaces.addAll(
      _prefixesToNamespaces(
        root,
        root.getAttribute("exclude-result-prefixes"),
      ),
    );
    _excludedNamespaces.addAll(
      _prefixesToNamespaces(
        root,
        root.getAttribute("extension-element-prefixes"),
      ),
    );

    final outputElement = root.childElements
        .where((e) => _isXslt(e, "output"))
        .lastOrNull;
    _stylesheet = Stylesheet._(version, _compileOutput(outputElement));

    for (final element in root.childElements) {
      if (_namespaceOf(element) != xsltNamespace) continue;

      switch (element.name.local) {
        case "template":
          _compileTemplate(element);
        case "variable" || "param":
          final name = _qname(element, _required(element, "name"));
          _stylesheet.globals[name] = GlobalVariable(
            name,
            _optionalExpression(element, "select"),
            _compileBody(element.children),
          );
        case "strip-space" || "preserve-space":
          _compileSpaceRules(element, element.name.local == "strip-space");
        case "key":
          final name = _qname(element, _required(element, "name"));
          _stylesheet.keys
              .putIfAbsent(name, () => [])
              .add(
                KeyDefinition(
                  _pattern(element, _required(element, "match")),
                  _expression(element, _required(element, "use")),
                ),
              );
        case "decimal-format":
          _compileDecimalFormat(element);
        case "attribute-set":
          final name = _qname(element, _required(element, "name"));
          _stylesheet.attributeSets.putIfAbsent(name, () => []).addAll([
            ..._useAttributeSets(element, "use-attribute-sets"),
            ..._compileBody(element.children),
          ]);
        case "output" || "namespace-alias":
          break;
        case "import" || "include":
          throw XsltException(
            "xsl:${element.name.local} of external stylesheets is not supported.",
          );
        default:
          if (version <= 1.0) {
            throw XsltException(
              "Unsupported top-level element xsl:${element.name.local}.",
            );
          }
      }
    }

    _stylesheet._sortRules();
    return _stylesheet;
  }

  OutputSettings _compileOutput(XmlElement? element) {
    if (element == null) return const OutputSettings();

    final method = switch (element.getAttribute("method")) {
      "xml" => OutputMethod.xml,
      "html" => OutputMethod.html,
      "xhtml" => OutputMethod.xhtml,
      "text" => OutputMethod.text,
      _ => null,
    };

    return OutputSettings(
      method: method,
      omitXmlDeclaration: element.getAttribute("omit-xml-declaration") == "yes",
      doctypePublic: element.getAttribute("doctype-public"),
      doctypeSystem: element.getAttribute("doctype-system"),
    );
  }

  void _compileTemplate(XmlElement element) {
    final match = element.getAttribute("match");
    final name = element.getAttribute("name");
    final mode = element.getAttribute("mode");
    final priority = element.getAttribute("priority");

    final parameters = <ParamInstruction>[];
    final bodyNodes = <XmlNode>[];
    for (final child in element.children) {
      if (child is XmlElement && _isXslt(child, "param") && bodyNodes.isEmpty) {
        parameters.add(_compileParam(child));
      } else {
        bodyNodes.add(child);
      }
    }

    final template = Template(
      name == null ? null : _qname(element, name),
      mode == null ? null : _qname(element, mode),
      parameters,
      _compileBody(bodyNodes),
    );

    if (name != null) {
      _stylesheet.namedTemplates[template.name!] = template;
    }

    if (match != null) {
      final pattern = _pattern(element, match);
      final position = _position++;
      final explicitPriority = priority == null
          ? null
          : double.tryParse(priority);

      for (final alternative in pattern.alternatives) {
        _stylesheet._addRule(
          template.mode,
          TemplateRule(
            alternative,
            explicitPriority ?? alternative.defaultPriority,
            position,
            template,
          ),
        );
      }
    }
  }

  ParamInstruction _compileParam(XmlElement element) {
    return ParamInstruction(
      _qname(element, _required(element, "name")),
      _optionalExpression(element, "select"),
      _compileBody(element.children),
    );
  }

  void _compileSpaceRules(XmlElement element, bool strip) {
    for (final token in _required(element, "elements").split(RegExp(r"\s+"))) {
      if (token.isEmpty) continue;

      final rule = switch (token) {
        "*" => _SpaceRule(
          null,
          null,
          strip,
          anyNamespace: true,
          priority: -0.5,
        ),
        _ when token.endsWith(":*") => _SpaceRule(
          _resolvePrefix(element, token.substring(0, token.length - 2)),
          null,
          strip,
          priority: -0.25,
        ),
        _ => () {
          final name = _qname(
            element,
            token,
            defaultNamespace: _xpathDefaultNamespace,
          );
          return _SpaceRule(name.namespace, name.local, strip, priority: 0);
        }(),
      };
      _stylesheet._spaceRules.add(rule);
    }
  }

  void _compileDecimalFormat(XmlElement element) {
    final name = element.getAttribute("name");
    String symbol(String attribute, String defaultValue) =>
        element.getAttribute(attribute) ?? defaultValue;

    _stylesheet.decimalFormats[name == null
        ? null
        : _qname(element, name)] = DecimalFormat(
      decimalSeparator: symbol("decimal-separator", "."),
      groupingSeparator: symbol("grouping-separator", ","),
      infinity: symbol("infinity", "Infinity"),
      minusSign: symbol("minus-sign", "-"),
      nan: symbol("NaN", "NaN"),
      percent: symbol("percent", "%"),
      perMille: symbol("per-mille", "‰"),
      zeroDigit: symbol("zero-digit", "0"),
      digit: symbol("digit", "#"),
      patternSeparator: symbol("pattern-separator", ";"),
    );
  }

  List<Instruction> _compileBody(Iterable<XmlNode> nodes) {
    final instructions = <Instruction>[];

    for (final node in nodes) {
      switch (node) {
        case XmlText() || XmlCDATA():
          if (node.value!.isNotEmpty) {
            instructions.add(TextInstruction(node.value!, false));
          }
        case XmlElement element:
          final instruction = _compileElement(element);
          if (instruction != null) instructions.add(instruction);
        default:
      }
    }

    return instructions;
  }

  Instruction? _compileElement(XmlElement element) {
    if (_namespaceOf(element) != xsltNamespace) {
      return _compileLiteralElement(element);
    }

    switch (element.name.local) {
      case "apply-templates":
        final mode = element.getAttribute("mode");
        return ApplyTemplatesInstruction(
          _optionalExpression(element, "select"),
          mode == null ? null : _qname(element, mode),
          _compileSorts(element),
          _compileWithParams(element),
        );

      case "call-template":
        return CallTemplateInstruction(
          _qname(element, _required(element, "name")),
          _compileWithParams(element),
        );

      case "for-each":
        return ForEachInstruction(
          _expression(element, _required(element, "select")),
          _compileSorts(element),
          _compileBody(
            element.children.where(
              (node) => !(node is XmlElement && _isXslt(node, "sort")),
            ),
          ),
        );

      case "value-of":
        return ValueOfInstruction(
          _expression(element, _required(element, "select")),
          element.getAttribute("disable-output-escaping") == "yes",
          element.getAttribute("separator") ??
              (_stylesheet.version >= 2 ? " " : null),
        );

      case "copy-of":
        return CopyOfInstruction(
          _expression(element, _required(element, "select")),
        );

      case "copy":
        return CopyInstruction(
          _useAttributeSets(element, "use-attribute-sets"),
          _compileBody(element.children),
        );

      case "if":
        return IfInstruction(
          _expression(element, _required(element, "test")),
          _compileBody(element.children),
        );

      case "choose":
        final whens = <(Expression, List<Instruction>)>[];
        List<Instruction>? otherwise;
        for (final child in element.childElements) {
          if (_isXslt(child, "when")) {
            whens.add((
              _expression(child, _required(child, "test")),
              _compileBody(child.children),
            ));
          } else if (_isXslt(child, "otherwise")) {
            otherwise = _compileBody(child.children);
          } else {
            throw const XsltException("Unexpected element in xsl:choose.");
          }
        }
        return ChooseInstruction(whens, otherwise);

      case "text":
        return TextInstruction(
          element.innerText,
          element.getAttribute("disable-output-escaping") == "yes",
        );

      case "variable":
        return VariableInstruction(
          _qname(element, _required(element, "name")),
          _optionalExpression(element, "select"),
          _compileBody(element.children),
        );

      case "param":
        throw const XsltException(
          "xsl:param must be the first child of a template.",
        );

      case "element":
        return ElementInstruction(
          _avt(element, _required(element, "name")),
          _optionalAvt(element, "namespace"),
          _namespaceResolver(element),
          _useAttributeSets(element, "use-attribute-sets"),
          _compileBody(element.children),
        );

      case "attribute":
        return AttributeInstruction(
          _avt(element, _required(element, "name")),
          _optionalAvt(element, "namespace"),
          _namespaceResolver(element),
          _optionalExpression(element, "select"),
          _compileBody(element.children),
        );

      case "comment":
        return CommentInstruction(_compileBody(element.children));

      case "processing-instruction":
        return ProcessingInstructionInstruction(
          _avt(element, _required(element, "name")),
          _compileBody(element.children),
        );

      case "number":
        return _compileNumber(element);

      case "message":
        return MessageInstruction(element.getAttribute("terminate") == "yes");

      case "fallback":
        return null;

      default:
        throw XsltException(
          "Unsupported instruction xsl:${element.name.local}.",
        );
    }
  }

  Instruction _compileNumber(XmlElement element) {
    final count = element.getAttribute("count");
    final from = element.getAttribute("from");

    return NumberInstruction(
      value: _optionalExpression(element, "value"),
      level: element.getAttribute("level") ?? "single",
      count: count == null ? null : _pattern(element, count),
      from: from == null ? null : _pattern(element, from),
      format: _optionalAvt(element, "format"),
      groupingSeparator: _optionalAvt(element, "grouping-separator"),
      groupingSize: _optionalAvt(element, "grouping-size"),
    );
  }

  Instruction _compileLiteralElement(XmlElement element) {
    final namespaces = <String, String>{};
    final excluded = {
      ..._excludedNamespaces,
      ..._prefixesToNamespaces(
        element,
        element.getAttribute(
          "exclude-result-prefixes",
          namespace: xsltNamespace,
        ),
      ),
    };

    _inScopeNamespaces(element).forEach((prefix, uri) {
      if (!excluded.contains(uri) && uri != xsltNamespace) {
        namespaces[prefix] = uri;
      }
    });

    final attributes = <(QName, String?, Avt)>[];
    for (final attribute in element.attributes) {
      final name = attribute.name;
      if (name.prefix == "xmlns" || name.qualified == "xmlns") continue;
      if (name.prefix != null &&
          _resolvePrefix(element, name.prefix!) == xsltNamespace) {
        continue;
      }

      attributes.add((
        name.prefix == null
            ? QName(null, name.local)
            : QName(_resolvePrefix(element, name.prefix!), name.local),
        name.prefix,
        _avt(element, attribute.value),
      ));
    }

    final useAttributeSets = <Instruction>[];
    for (final attribute in element.attributes) {
      if (attribute.name.local == "use-attribute-sets" &&
          attribute.name.prefix != null &&
          _resolvePrefix(element, attribute.name.prefix!) == xsltNamespace) {
        useAttributeSets.addAll(
          _attributeSetReferences(element, attribute.value),
        );
      }
    }

    return LiteralElementInstruction(
      QName(_namespaceOf(element), element.name.local),
      element.name.prefix,
      namespaces,
      attributes,
      useAttributeSets,
      _compileBody(element.children),
    );
  }

  List<SortKey> _compileSorts(XmlElement element) {
    return [
      for (final sort in element.childElements.where((e) => _isXslt(e, "sort")))
        SortKey(
          _optionalExpression(sort, "select") ??
              const LocationPath(false, [
                Step(Axis.self, NodeTypeTest(NodeType.node), []),
              ]),
          _optionalAvt(sort, "order"),
          _optionalAvt(sort, "data-type"),
          _optionalAvt(sort, "case-order"),
        ),
    ];
  }

  List<WithParam> _compileWithParams(XmlElement element) {
    return [
      for (final child in element.childElements.where(
        (e) => _isXslt(e, "with-param"),
      ))
        WithParam(
          _qname(child, _required(child, "name")),
          _optionalExpression(child, "select"),
          _compileBody(child.children),
        ),
    ];
  }

  List<Instruction> _useAttributeSets(XmlElement element, String attribute) {
    final value = element.getAttribute(attribute);
    return value == null ? const [] : _attributeSetReferences(element, value);
  }

  List<Instruction> _attributeSetReferences(XmlElement element, String value) {
    return [
      for (final name in value.split(RegExp(r"\s+")))
        if (name.isNotEmpty) UseAttributeSetInstruction(_qname(element, name)),
    ];
  }

  // --- helpers

  XPathParser _parser(XmlElement element) => XPathParser(
    (prefix) => _inScopeNamespaces(element)[prefix],
    defaultElementNamespace: _xpathDefaultNamespace,
  );

  Expression _expression(XmlElement element, String value) {
    try {
      return _parser(element).parse(value);
    } on XPathException catch (e) {
      throw XsltException(e.message);
    }
  }

  Expression? _optionalExpression(XmlElement element, String attribute) {
    final value = element.getAttribute(attribute);
    return value == null ? null : _expression(element, value);
  }

  Pattern _pattern(XmlElement element, String value) {
    try {
      return Pattern.fromExpression(_parser(element).parse(value), value);
    } on XPathException catch (e) {
      throw XsltException(e.message);
    }
  }

  Avt _avt(XmlElement element, String value) {
    try {
      return Avt.parse(value, _parser(element));
    } on XPathException catch (e) {
      throw XsltException(e.message);
    }
  }

  Avt? _optionalAvt(XmlElement element, String attribute) {
    final value = element.getAttribute(attribute);
    return value == null ? null : _avt(element, value);
  }

  NamespaceResolver _namespaceResolver(XmlElement element) {
    final namespaces = _inScopeNamespaces(element);
    return (prefix) => namespaces[prefix];
  }

  String _required(XmlElement element, String attribute) {
    return element.getAttribute(attribute) ??
        (throw XsltException(
          "Missing attribute '$attribute' of ${element.name.qualified}.",
        ));
  }

  QName _qname(XmlElement element, String value, {String? defaultNamespace}) {
    final colon = value.indexOf(":");
    if (colon < 0) return QName(defaultNamespace, value);

    return QName(
      _resolvePrefix(element, value.substring(0, colon)),
      value.substring(colon + 1),
    );
  }

  String _resolvePrefix(XmlElement element, String prefix) {
    if (prefix == "xml") return xmlNamespace;

    final uri = _inScopeNamespaces(element)[prefix];
    if (uri == null || uri.isEmpty) {
      throw XsltException("Undeclared namespace prefix '$prefix'.");
    }
    return uri;
  }

  Set<String> _prefixesToNamespaces(XmlElement element, String? prefixes) {
    if (prefixes == null) return const {};

    final namespaces = _inScopeNamespaces(element);
    return {
      for (final prefix in prefixes.split(RegExp(r"\s+")))
        if (prefix == "#default" && namespaces.containsKey(""))
          namespaces[""]!
        else if (prefix == "#all")
          ...namespaces.values
        else if (namespaces.containsKey(prefix))
          namespaces[prefix]!,
    };
  }

  final _namespaceCache = Expando<Map<String, String>>();

  Map<String, String> _inScopeNamespaces(XmlNode node) {
    final cached = _namespaceCache[node];
    if (cached != null) return cached;

    final parent = node.parent;
    final namespaces = parent is XmlElement
        ? Map.of(_inScopeNamespaces(parent))
        : <String, String>{};

    for (final attribute in node.attributes) {
      final name = attribute.name;
      if (name.prefix == null && name.local == "xmlns") {
        namespaces[""] = attribute.value;
      } else if (name.prefix == "xmlns") {
        namespaces[name.local] = attribute.value;
      }
    }
    namespaces.removeWhere((prefix, uri) => uri.isEmpty);

    return _namespaceCache[node] = namespaces;
  }

  String? _namespaceOf(XmlElement element) =>
      _inScopeNamespaces(element)[element.name.prefix ?? ""];

  bool _isXslt(XmlElement element, String localName) =>
      element.name.local == localName && _namespaceOf(element) == xsltNamespace;

  /// Removes comments and processing instructions of the stylesheet, merges
  /// adjacent text nodes and strips whitespace-only text nodes except of
  /// `xsl:text` and elements with `xml:space="preserve"`.
  void _stripWhitespace(XmlElement element, bool preserve) {
    final space = element.getAttribute("xml:space");
    final preserveHere = space == null ? preserve : space == "preserve";
    final isText = _isXslt(element, "text");

    final children = element.children.toList();
    element.children.clear();

    final merged = <XmlNode>[];
    for (final child in children) {
      if (child is XmlComment || child is XmlProcessing) continue;

      final last = merged.isEmpty ? null : merged.last;
      if ((child is XmlText || child is XmlCDATA) && last is XmlText) {
        merged[merged.length - 1] = XmlText(last.value + child.value!);
      } else if (child is XmlCDATA) {
        merged.add(XmlText(child.value));
      } else {
        merged.add(child);
      }
    }

    element.children.addAll(merged.where((node) =>
          node is! XmlText ||
          isText ||
          preserveHere ||
          !isXmlWhitespace(node.value)));

    for (final child in element.childElements) {
      _stripWhitespace(child, preserveHere);
    }
  }
}
