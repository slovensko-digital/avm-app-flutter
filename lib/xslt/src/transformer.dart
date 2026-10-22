import 'errors.dart';
import 'format_number.dart';
import 'instructions.dart';
import 'nodes.dart';
import 'output.dart';
import 'stylesheet.dart';
import 'xpath/ast.dart';
import 'xpath/functions.dart';
import 'xpath/values.dart';

const _exsltCommonNamespace = "http://exslt.org/common";
const _msxslNamespace = "urn:schemas-microsoft-com:xslt";

/// Local variables and parameters in scope.
class Scope {
  final QName name;
  final Object value;
  final Scope? parent;

  const Scope(this.name, this.value, this.parent);
}

/// Context of instruction execution.
class ExecutionContext {
  final XNode node;
  final int position;
  final int size;
  final Scope? scope;
  final ResultBuilder output;

  const ExecutionContext(
    this.node,
    this.position,
    this.size,
    this.scope,
    this.output,
  );

  ExecutionContext at(XNode node, int position, int size) =>
      ExecutionContext(node, position, size, scope, output);

  ExecutionContext bind(QName name, Object value) =>
      ExecutionContext(node, position, size, Scope(name, value, scope), output);

  ExecutionContext withOutput(ResultBuilder output) =>
      ExecutionContext(node, position, size, scope, output);
}

/// Executes compiled [Stylesheet] on a source tree.
class Transformer {
  static const _maxDepth = 2000;

  final Stylesheet stylesheet;
  final Map<QName, Object> _globalValues = {};
  final Set<QName> _evaluatingGlobals = {};
  final Map<(QName, XTree), Map<String, List<XNode>>> _keyIndexes = {};
  final Set<QName> _activeAttributeSets = {};
  var _depth = 0;

  late XRoot _source;

  Transformer(this.stylesheet);

  /// Transforms [source] and returns the result tree.
  XRoot transform(XRoot source) {
    _source = source;
    final output = ResultBuilder();
    final context = ExecutionContext(source, 1, 1, null, output);

    applyTemplates([source], null, const {}, context);
    return output.root;
  }

  // --- execution

  void executeBody(List<Instruction> body, ExecutionContext context) {
    var current = context;

    for (final instruction in body) {
      if (instruction is VariableInstruction) {
        current = current.bind(
          instruction.name,
          _variableValue(instruction.select, instruction.body, current),
        );
      } else {
        instruction.execute(this, current);
      }
    }
  }

  void applyTemplates(
    List<XNode> nodes,
    QName? mode,
    Map<QName, Object> parameters,
    ExecutionContext context,
  ) {
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final nodeContext = context.at(node, i + 1, nodes.length);
      final rule = stylesheet.findRule(node, mode, xpathContext(nodeContext));

      if (rule != null) {
        invokeTemplate(rule.template, nodeContext, parameters);
      } else {
        _builtInRule(node, mode, nodeContext);
      }
    }
  }

  void _builtInRule(XNode node, QName? mode, ExecutionContext context) {
    switch (node) {
      case XParent parent:
        applyTemplates(parent.children, mode, const {}, context);
      case XText() || XAttribute():
        context.output.text(node.stringValue);
      default:
    }
  }

  void invokeTemplate(
    Template template,
    ExecutionContext context,
    Map<QName, Object> parameters,
  ) {
    if (++_depth > _maxDepth) {
      throw const XsltException("Too deep recursion of templates.");
    }

    try {
      // templates don't see local variables of the caller
      var templateContext = ExecutionContext(
        context.node,
        context.position,
        context.size,
        null,
        context.output,
      );

      for (final parameter in template.parameters) {
        final value = parameters.containsKey(parameter.name)
            ? parameters[parameter.name]!
            : _variableValue(parameter.select, parameter.body, templateContext);
        templateContext = templateContext.bind(parameter.name, value);
      }

      executeBody(template.body, templateContext);
    } finally {
      _depth--;
    }
  }

  Map<QName, Object> evaluateParameters(
    List<WithParam> parameters,
    ExecutionContext context,
  ) {
    if (parameters.isEmpty) return const {};

    return {
      for (final parameter in parameters)
        parameter.name: _variableValue(
          parameter.select,
          parameter.body,
          context,
        ),
    };
  }

  Object _variableValue(
    Expression? select,
    List<Instruction> body,
    ExecutionContext context,
  ) {
    if (select != null) {
      return select.evaluate(xpathContext(context));
    }

    if (body.isEmpty) return "";

    // result tree fragment
    final fragment = ResultBuilder();
    executeBody(body, context.withOutput(fragment));
    return NodeSet([fragment.root]);
  }

  /// Evaluates [body] to string - content of attribute, comment etc.
  String evaluateText(List<Instruction> body, ExecutionContext context) {
    if (body.isEmpty) return "";

    final fragment = ResultBuilder();
    executeBody(body, context.withOutput(fragment));
    return fragment.root.stringValue;
  }

  void useAttributeSet(
    QName name,
    List<Instruction> instructions,
    ExecutionContext context,
  ) {
    if (!_activeAttributeSets.add(name)) {
      throw XsltException("Circular reference of attribute set '$name'.");
    }

    try {
      // attribute sets see only global variables
      executeBody(
        instructions,
        ExecutionContext(
          context.node,
          context.position,
          context.size,
          null,
          context.output,
        ),
      );
    } finally {
      _activeAttributeSets.remove(name);
    }
  }

  NodeSet evaluateNodeSet(Expression expression, ExecutionContext context) {
    final value = expression.evaluate(xpathContext(context));
    if (value is NodeSet) return value;

    throw XsltException("Expression doesn't select nodes: $expression");
  }

  List<XNode> sort(
    List<XNode> nodes,
    List<SortKey> keys,
    ExecutionContext context,
  ) {
    if (keys.isEmpty || nodes.length < 2) return nodes;

    final size = nodes.length;
    final settings = [
      for (final key in keys)
        (
          descending:
              key.order?.evaluate(xpathContext(context)) == "descending",
          numeric: key.dataType?.evaluate(xpathContext(context)) == "number",
          upperFirst:
              key.caseOrder?.evaluate(xpathContext(context)) == "upper-first",
        ),
    ];

    final values = [
      for (var i = 0; i < size; i++)
        [
          for (var k = 0; k < keys.length; k++)
            settings[k].numeric
                ? keys[k].select.evaluateNumber(
                    xpathContext(context.at(nodes[i], i + 1, size)),
                  )
                : keys[k].select.evaluateString(
                    xpathContext(context.at(nodes[i], i + 1, size)),
                  ),
        ],
    ];

    final indexes = List.generate(size, (i) => i);
    indexes.sort((a, b) {
      for (var k = 0; k < keys.length; k++) {
        final setting = settings[k];
        var result = setting.numeric
            ? _compareNumbers(values[a][k] as double, values[b][k] as double)
            : _compareStrings(
                values[a][k] as String,
                values[b][k] as String,
                setting.upperFirst,
              );
        if (setting.descending) result = -result;
        if (result != 0) return result;
      }
      return a.compareTo(b);
    });

    return [for (final i in indexes) nodes[i]];
  }

  static int _compareNumbers(double a, double b) {
    if (a.isNaN) return b.isNaN ? 0 : -1;
    if (b.isNaN) return 1;
    return a.compareTo(b);
  }

  static int _compareStrings(String a, String b, bool upperFirst) {
    final result = a.toLowerCase().compareTo(b.toLowerCase());
    if (result != 0) return result;

    final cased = a.compareTo(b);
    return upperFirst ? cased : -cased;
  }

  // --- XPath

  XPathContext xpathContext(ExecutionContext context) => XPathContext(
    context.node,
    context.position,
    context.size,
    _Environment(this, context.scope, context.node),
  );

  Object globalValue(QName name) {
    final cached = _globalValues[name];
    if (cached != null) return cached;

    final variable =
        stylesheet.globals[name] ??
        (throw XPathException("Variable '$name' is not declared."));

    if (!_evaluatingGlobals.add(name)) {
      throw XsltException("Circular definition of variable '$name'.");
    }

    try {
      final context = ExecutionContext(_source, 1, 1, null, ResultBuilder());
      return _globalValues[name] = _variableValue(
        variable.select,
        variable.body,
        context,
      );
    } finally {
      _evaluatingGlobals.remove(name);
    }
  }

  NodeSet key(QName name, Object value, XNode contextNode, XPathContext xpath) {
    final definitions =
        stylesheet.keys[name] ??
        (throw XsltException("Key '$name' is not declared."));

    final root = contextNode.root;
    final index = _keyIndexes.putIfAbsent((name, root.tree), () {
      final result = <String, List<XNode>>{};
      final nodes = [root, ...axisNodes(Axis.descendant, root)];
      final withAttributes = [
        for (final node in nodes) ...[
          node,
          if (node is XElement) ...node.attributes,
        ],
      ];

      for (final definition in definitions) {
        for (final node in withAttributes) {
          final nodeContext = xpath.withNode(node, 1, 1);
          if (!definition.match.matches(node, nodeContext)) continue;

          final use = definition.use.evaluate(nodeContext);
          final keys = use is NodeSet
              ? use.nodes.map((n) => n.stringValue)
              : [toXPathString(use)];
          for (final key in keys) {
            result.putIfAbsent(key, () => []).add(node);
          }
        }
      }
      return result;
    });

    final values = value is NodeSet
        ? value.nodes.map((node) => node.stringValue)
        : [toXPathString(value)];

    return NodeSet.unordered([
      for (final v in values) ...?index[v],
    ]);
  }
}

class _Environment implements XPathEnvironment {
  final Transformer transformer;
  final Scope? scope;
  final XNode current;

  _Environment(this.transformer, this.scope, this.current);

  @override
  Object variable(QName name) {
    for (var s = scope; s != null; s = s.parent) {
      if (s.name == name) return s.value;
    }

    return transformer.globalValue(name);
  }

  @override
  Object callFunction(QName name, List<Expression> args, XPathContext context) {
    if (name.namespace == null) {
      final core = coreFunctions[name.local];
      if (core != null) return core(context, args);

      switch (name.local) {
        case "current":
          return NodeSet([current]);
        case "key":
          _arity(name, args, 2);
          return transformer.key(
            _qname(args[0].evaluateString(context)),
            args[1].evaluate(context),
            context.node,
            context,
          );
        case "generate-id":
          final node = args.isEmpty
              ? context.node
              : args[0].evaluateNodeSet(context).first;
          return node == null ? "" : "d${node.tree.id}n${node.order}";
        case "format-number":
          _arity(name, args, 2, 3);
          final format = args.length > 2
              ? transformer.stylesheet.decimalFormats[_qname(
                  args[2].evaluateString(context),
                )]
              : transformer.stylesheet.decimalFormats[null];
          return formatNumber(
            args[0].evaluateNumber(context),
            args[1].evaluateString(context),
            format ?? const DecimalFormat(),
          );
        case "system-property":
          return switch (args.single.evaluateString(context)) {
            "xsl:version" => 1.0,
            "xsl:vendor" => "Autogram v mobile",
            _ => "",
          };
        case "element-available":
          return const {
            "apply-templates", "attribute", "call-template", "choose", //
            "comment", "copy", "copy-of", "element", "for-each", "if",
            "message", "number", "processing-instruction", "text",
            "value-of", "variable",
          }.contains(_localName(args.single.evaluateString(context)));
        case "function-available":
          final function = args.single.evaluateString(context);
          return coreFunctions.containsKey(function) ||
              const {
                "current",
                "key",
                "generate-id",
                "format-number",
                "system-property",
                "element-available",
                "function-available",
              }.contains(function) ||
              function.endsWith(":node-set");
        case "unparsed-entity-uri":
          return "";
        case "document":
          throw const XsltException("document() function is not supported.");
      }
    } else if ((name.namespace == _exsltCommonNamespace ||
            name.namespace == _msxslNamespace) &&
        name.local == "node-set") {
      _arity(name, args, 1);
      final value = args[0].evaluate(context);
      if (value is NodeSet) return value;

      final fragment = ResultBuilder()..text(toXPathString(value));
      return NodeSet([fragment.root]);
    }

    throw XPathException("Unknown function $name().");
  }

  /// Resolves QName from string value - only unprefixed names are supported
  /// at run time.
  QName _qname(String value) => QName(null, value.trim());

  static String _localName(String value) {
    final colon = value.indexOf(":");
    return colon < 0 ? value : value.substring(colon + 1);
  }

  static void _arity(QName name, List<Expression> args, int min, [int? max]) {
    max ??= min;
    if (args.length < min || args.length > max) {
      throw XPathException("Wrong number of arguments of $name().");
    }
  }
}
