import 'avt.dart';
import 'errors.dart';
import 'nodes.dart';
import 'patterns.dart';
import 'transformer.dart';
import 'xpath/ast.dart';
import 'xpath/parser.dart';
import 'xpath/values.dart';

/// Compiled XSLT instruction.
sealed class Instruction {
  const Instruction();

  void execute(Transformer transformer, ExecutionContext context);
}

class TextInstruction extends Instruction {
  final String text;
  final bool disableEscaping;

  const TextInstruction(this.text, this.disableEscaping);

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    context.output.text(text, disableEscaping: disableEscaping);
  }
}

class LiteralElementInstruction extends Instruction {
  final QName name;
  final String? prefix;
  final Map<String, String> namespaces;
  final List<(QName, String?, Avt)> attributes;
  final List<Instruction> useAttributeSets;
  final List<Instruction> body;

  const LiteralElementInstruction(
    this.name,
    this.prefix,
    this.namespaces,
    this.attributes,
    this.useAttributeSets,
    this.body,
  );

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    final output = context.output;
    output.startElement(name, prefix, namespaces);

    for (final instruction in useAttributeSets) {
      instruction.execute(transformer, context);
    }

    if (attributes.isNotEmpty) {
      final xpath = transformer.xpathContext(context);
      for (final (name, prefix, value) in attributes) {
        output.attribute(name, prefix, value.evaluate(xpath));
      }
    }

    transformer.executeBody(body, context);
    output.endElement();
  }
}

class ApplyTemplatesInstruction extends Instruction {
  final Expression? select;
  final QName? mode;
  final List<SortKey> sorts;
  final List<WithParam> parameters;

  const ApplyTemplatesInstruction(
    this.select,
    this.mode,
    this.sorts,
    this.parameters,
  );

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    final List<XNode> nodes;
    final select = this.select;
    if (select == null) {
      final node = context.node;
      nodes = node is XParent ? node.children : const [];
    } else {
      nodes = transformer.evaluateNodeSet(select, context).nodes;
    }

    transformer.applyTemplates(
      transformer.sort(nodes, sorts, context),
      mode,
      transformer.evaluateParameters(parameters, context),
      context,
    );
  }
}

class CallTemplateInstruction extends Instruction {
  final QName name;
  final List<WithParam> parameters;

  const CallTemplateInstruction(this.name, this.parameters);

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    final template =
        transformer.stylesheet.namedTemplates[name] ??
        (throw XsltException("Template '$name' not found."));

    transformer.invokeTemplate(
      template,
      context,
      transformer.evaluateParameters(parameters, context),
    );
  }
}

class ForEachInstruction extends Instruction {
  final Expression select;
  final List<SortKey> sorts;
  final List<Instruction> body;

  const ForEachInstruction(this.select, this.sorts, this.body);

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    final nodes = transformer.sort(
      transformer.evaluateNodeSet(select, context).nodes,
      sorts,
      context,
    );

    for (var i = 0; i < nodes.length; i++) {
      transformer.executeBody(body, context.at(nodes[i], i + 1, nodes.length));
    }
  }
}

class ValueOfInstruction extends Instruction {
  final Expression select;
  final bool disableEscaping;

  /// Separator of node values (XSLT 2.0), only the first node is used in
  /// XSLT 1.0.
  final String? separator;

  const ValueOfInstruction(this.select, this.disableEscaping, this.separator);

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    final value = select.evaluate(transformer.xpathContext(context));
    final separator = this.separator;

    final text = value is NodeSet && separator != null
        ? value.nodes.map((node) => node.stringValue).join(separator)
        : toXPathString(value);

    context.output.text(text, disableEscaping: disableEscaping);
  }
}

class CopyOfInstruction extends Instruction {
  final Expression select;

  const CopyOfInstruction(this.select);

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    final value = select.evaluate(transformer.xpathContext(context));

    if (value is NodeSet) {
      for (final node in value.nodes) {
        context.output.copy(node);
      }
    } else {
      context.output.text(toXPathString(value));
    }
  }
}

class CopyInstruction extends Instruction {
  final List<Instruction> useAttributeSets;
  final List<Instruction> body;

  const CopyInstruction(this.useAttributeSets, this.body);

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    final output = context.output;

    switch (context.node) {
      case XRoot _:
        transformer.executeBody(body, context);
      case XElement element:
        output.startElement(
          element.name,
          element.prefix,
          element.inScopeNamespaces,
        );
        for (final instruction in useAttributeSets) {
          instruction.execute(transformer, context);
        }
        transformer.executeBody(body, context);
        output.endElement();
      case final node:
        output.copy(node);
    }
  }
}

class IfInstruction extends Instruction {
  final Expression test;
  final List<Instruction> body;

  const IfInstruction(this.test, this.body);

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    if (test.evaluateBoolean(transformer.xpathContext(context))) {
      transformer.executeBody(body, context);
    }
  }
}

class ChooseInstruction extends Instruction {
  final List<(Expression, List<Instruction>)> whens;
  final List<Instruction>? otherwise;

  const ChooseInstruction(this.whens, this.otherwise);

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    final xpath = transformer.xpathContext(context);

    for (final (test, body) in whens) {
      if (test.evaluateBoolean(xpath)) {
        transformer.executeBody(body, context);
        return;
      }
    }

    final otherwise = this.otherwise;
    if (otherwise != null) transformer.executeBody(otherwise, context);
  }
}

/// Local `xsl:variable` - bound by [Transformer.executeBody].
class VariableInstruction extends Instruction {
  final QName name;
  final Expression? select;
  final List<Instruction> body;

  const VariableInstruction(this.name, this.select, this.body);

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    throw StateError("Variable is bound by the body execution.");
  }
}

/// `xsl:param` of template.
class ParamInstruction extends VariableInstruction {
  const ParamInstruction(super.name, super.select, super.body);
}

class WithParam {
  final QName name;
  final Expression? select;
  final List<Instruction> body;

  const WithParam(this.name, this.select, this.body);
}

class SortKey {
  final Expression select;
  final Avt? order;
  final Avt? dataType;
  final Avt? caseOrder;

  const SortKey(this.select, this.order, this.dataType, this.caseOrder);
}

class ElementInstruction extends Instruction {
  final Avt name;
  final Avt? namespace;
  final NamespaceResolver resolver;
  final List<Instruction> useAttributeSets;
  final List<Instruction> body;

  const ElementInstruction(
    this.name,
    this.namespace,
    this.resolver,
    this.useAttributeSets,
    this.body,
  );

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    final xpath = transformer.xpathContext(context);
    final (qname, prefix) = _resolveName(
      name.evaluate(xpath),
      namespace?.evaluate(xpath),
      resolver,
      isAttribute: false,
    );

    final output = context.output;
    output.startElement(qname, prefix, const {});
    for (final instruction in useAttributeSets) {
      instruction.execute(transformer, context);
    }
    transformer.executeBody(body, context);
    output.endElement();
  }
}

class AttributeInstruction extends Instruction {
  final Avt name;
  final Avt? namespace;
  final NamespaceResolver resolver;
  final Expression? select;
  final List<Instruction> body;

  const AttributeInstruction(
    this.name,
    this.namespace,
    this.resolver,
    this.select,
    this.body,
  );

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    final xpath = transformer.xpathContext(context);
    final (qname, prefix) = _resolveName(
      name.evaluate(xpath),
      namespace?.evaluate(xpath),
      resolver,
      isAttribute: true,
    );
    if (qname.namespace == null && qname.local == "xmlns") return;

    final select = this.select;
    final value = select != null
        ? select.evaluateString(xpath)
        : transformer.evaluateText(body, context);

    context.output.attribute(qname, prefix, value);
  }
}

(QName, String?) _resolveName(
  String name,
  String? namespace,
  NamespaceResolver resolver, {
  required bool isAttribute,
}) {
  name = name.trim();
  final colon = name.indexOf(":");
  final prefix = colon < 0 ? null : name.substring(0, colon);
  final local = colon < 0 ? name : name.substring(colon + 1);

  if (local.isEmpty) {
    throw XsltException("Invalid name '$name'.");
  }

  if (namespace != null) {
    return (QName(namespace.isEmpty ? null : namespace, local), prefix);
  }

  if (prefix == null) {
    final defaultNamespace = isAttribute ? null : resolver("");
    return (QName(defaultNamespace, local), null);
  }

  final uri = prefix == "xml" ? xmlNamespace : resolver(prefix);
  if (uri == null) {
    throw XsltException("Undeclared namespace prefix '$prefix'.");
  }

  return (QName(uri, local), prefix);
}

class CommentInstruction extends Instruction {
  final List<Instruction> body;

  const CommentInstruction(this.body);

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    context.output.comment(transformer.evaluateText(body, context));
  }
}

class ProcessingInstructionInstruction extends Instruction {
  final Avt name;
  final List<Instruction> body;

  const ProcessingInstructionInstruction(this.name, this.body);

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    final target = name.evaluate(transformer.xpathContext(context)).trim();
    context.output.processingInstruction(
      target,
      transformer.evaluateText(body, context),
    );
  }
}

class MessageInstruction extends Instruction {
  final bool terminate;

  const MessageInstruction(this.terminate);

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    if (terminate) {
      throw const XsltException("Transformation terminated by xsl:message.");
    }
  }
}

class UseAttributeSetInstruction extends Instruction {
  final QName name;

  const UseAttributeSetInstruction(this.name);

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    final attributeSet =
        transformer.stylesheet.attributeSets[name] ??
        (throw XsltException("Attribute set '$name' not found."));

    transformer.useAttributeSet(name, attributeSet, context);
  }
}

class NumberInstruction extends Instruction {
  final Expression? value;
  final String level;
  final Pattern? count;
  final Pattern? from;
  final Avt? format;
  final Avt? groupingSeparator;
  final Avt? groupingSize;

  const NumberInstruction({
    required this.value,
    required this.level,
    required this.count,
    required this.from,
    required this.format,
    required this.groupingSeparator,
    required this.groupingSize,
  });

  @override
  void execute(Transformer transformer, ExecutionContext context) {
    final xpath = transformer.xpathContext(context);
    final List<int> numbers;

    final value = this.value;
    if (value != null) {
      final number = value.evaluateNumber(xpath);
      if (!number.isFinite) {
        context.output.text(toXPathString(number));
        return;
      }
      numbers = [_round(number)];
    } else {
      numbers = _count(context.node, xpath);
    }

    final formatted = formatNumberSequence(
      numbers,
      format?.evaluate(xpath) ?? "1",
      groupingSeparator?.evaluate(xpath),
      int.tryParse(groupingSize?.evaluate(xpath) ?? ""),
    );
    context.output.text(formatted);
  }

  static int _round(double number) => (number + 0.5).floor();

  List<int> _count(XNode node, XPathContext xpath) {
    bool matchesCount(XNode candidate) {
      final count = this.count;
      if (count != null) return count.matches(candidate, xpath);

      return switch ((node, candidate)) {
        (XElement a, XElement b) => a.name == b.name,
        (XAttribute a, XAttribute b) => a.name == b.name,
        (XProcessingInstruction a, XProcessingInstruction b) =>
          a.target == b.target,
        _ => node.runtimeType == candidate.runtimeType,
      };
    }

    bool matchesFrom(XNode candidate) =>
        from != null && from!.matches(candidate, xpath);

    int precedingSiblings(XNode n) {
      final parent = n.parent;
      if (parent is! XParent) return 0;

      var result = 0;
      for (final sibling in parent.children) {
        if (identical(sibling, n)) break;
        if (matchesCount(sibling)) result++;
      }
      return result;
    }

    switch (level) {
      case "multiple":
        final result = <int>[];
        for (XNode? n = node; n != null && !matchesFrom(n); n = n.parent) {
          if (matchesCount(n)) result.insert(0, precedingSiblings(n) + 1);
        }
        return result;

      case "any":
        var result = 0;
        for (final n in axisNodes(
          Axis.ancestorOrSelf,
          node,
        ).toList().reversed) {
          if (matchesCount(n)) result++;
        }
        for (final n in axisNodes(Axis.preceding, node)) {
          if (matchesFrom(n)) break;
          if (matchesCount(n)) result++;
        }
        return result == 0 ? const [] : [result];

      default:
        for (XNode? n = node; n != null && !matchesFrom(n); n = n.parent) {
          if (matchesCount(n)) return [precedingSiblings(n) + 1];
        }
        return const [];
    }
  }
}

/// Formats numbers of `xsl:number` according to the [format] tokens.
String formatNumberSequence(
  List<int> numbers,
  String format,
  String? groupingSeparator,
  int? groupingSize,
) {
  final tokens = RegExp(
    r"[\p{L}\p{N}]+",
    unicode: true,
  ).allMatches(format).toList();
  if (tokens.isEmpty) return numbers.join(".");

  final prefix = format.substring(0, tokens.first.start);
  final suffix = format.substring(tokens.last.end);
  final buffer = StringBuffer(prefix);

  for (var i = 0; i < numbers.length; i++) {
    final tokenIndex = i < tokens.length ? i : tokens.length - 1;
    if (i > 0) {
      final separator = tokenIndex > 0
          ? format.substring(
              tokens[tokenIndex - 1].end,
              tokens[tokenIndex].start,
            )
          : ".";
      buffer.write(separator.isEmpty ? "." : separator);
    }

    buffer.write(
      _formatToken(
        numbers[i],
        tokens[tokenIndex].group(0)!,
        groupingSeparator,
        groupingSize,
      ),
    );
  }

  buffer.write(suffix);
  return buffer.toString();
}

String _formatToken(int number, String token, String? separator, int? size) {
  switch (token) {
    case "a" || "A":
      final letters = StringBuffer();
      var n = number;
      while (n > 0) {
        n--;
        letters.write(String.fromCharCode(token.codeUnitAt(0) + n % 26));
        n ~/= 26;
      }
      return letters.toString().split("").reversed.join();
    case "i" || "I":
      final roman = _roman(number);
      return token == "i" ? roman.toLowerCase() : roman;
  }

  var digits = number.toString().padLeft(token.length, "0");
  if (separator != null && size != null && size > 0) {
    final groups = <String>[];
    while (digits.length > size) {
      groups.insert(0, digits.substring(digits.length - size));
      digits = digits.substring(0, digits.length - size);
    }
    groups.insert(0, digits);
    digits = groups.join(separator);
  }
  return digits;
}

String _roman(int number) {
  if (number <= 0 || number >= 4000) return number.toString();

  const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
  const symbols = [
    "M",
    "CM",
    "D",
    "CD",
    "C",
    "XC",
    "L",
    "XL",
    "X",
    "IX",
    "V",
    "IV",
    "I",
  ];
  final buffer = StringBuffer();
  for (var i = 0; i < values.length; i++) {
    while (number >= values[i]) {
      buffer.write(symbols[i]);
      number -= values[i];
    }
  }
  return buffer.toString();
}
