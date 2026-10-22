import '../errors.dart';
import '../nodes.dart';
import 'values.dart';

/// Environment of XPath evaluation - variables and functions.
abstract class XPathEnvironment {
  /// Gets value of the variable or throws [XPathException].
  Object variable(QName name);

  /// Calls the function or throws [XPathException] when it doesn't exist.
  Object callFunction(
    QName name,
    List<Expression> arguments,
    XPathContext context,
  );
}

/// Dynamic context of XPath evaluation.
class XPathContext {
  final XNode node;
  final int position;
  final int size;
  final XPathEnvironment environment;

  const XPathContext(this.node, this.position, this.size, this.environment);

  XPathContext withNode(XNode node, int position, int size) =>
      XPathContext(node, position, size, environment);
}

/// Compiled XPath expression.
sealed class Expression {
  const Expression();

  Object evaluate(XPathContext context);

  NodeSet evaluateNodeSet(XPathContext context) {
    final value = evaluate(context);
    if (value is NodeSet) return value;

    throw XPathException("Expression doesn't evaluate to a node-set: $this");
  }

  String evaluateString(XPathContext context) =>
      toXPathString(evaluate(context));

  double evaluateNumber(XPathContext context) =>
      toXPathNumber(evaluate(context));

  bool evaluateBoolean(XPathContext context) =>
      toXPathBoolean(evaluate(context));
}

class OrExpression extends Expression {
  final Expression left, right;

  const OrExpression(this.left, this.right);

  @override
  Object evaluate(XPathContext context) =>
      left.evaluateBoolean(context) || right.evaluateBoolean(context);
}

class AndExpression extends Expression {
  final Expression left, right;

  const AndExpression(this.left, this.right);

  @override
  Object evaluate(XPathContext context) =>
      left.evaluateBoolean(context) && right.evaluateBoolean(context);
}

enum ComparisonOperator {
  equals,
  notEquals,
  less,
  lessOrEqual,
  greater,
  greaterOrEqual,
}

class ComparisonExpression extends Expression {
  final ComparisonOperator operator;
  final Expression left, right;

  const ComparisonExpression(this.operator, this.left, this.right);

  @override
  Object evaluate(XPathContext context) =>
      compareValues(operator, left.evaluate(context), right.evaluate(context));
}

/// Compares XPath values according to XPath 1.0 section 3.4.
bool compareValues(ComparisonOperator operator, Object a, Object b) {
  if (a is NodeSet && b is NodeSet) {
    if (_isRelational(operator)) {
      final numbersB = [
        for (final node in b.nodes) stringToNumber(node.stringValue),
      ];
      return a.nodes.any((node) {
        final number = stringToNumber(node.stringValue);
        return numbersB.any(
          (other) => _compareNumbers(operator, number, other),
        );
      });
    }

    final stringsB = {for (final node in b.nodes) node.stringValue};
    if (operator == ComparisonOperator.equals) {
      return a.nodes.any((node) => stringsB.contains(node.stringValue));
    }
    return a.nodes.any(
      (node) => stringsB.any((other) => node.stringValue != other),
    );
  }

  if (a is NodeSet || b is NodeSet) {
    final swapped = b is NodeSet;
    final set = (swapped ? b : a) as NodeSet;
    final other = swapped ? a : b;
    final effective = swapped ? _swap(operator) : operator;

    switch (other) {
      case bool value:
        return _compareBooleans(effective, !set.isEmpty, value);
      case double _ || int _:
        final number = toXPathNumber(other);
        return set.nodes.any(
          (node) => _compareNumbers(
            effective,
            stringToNumber(node.stringValue),
            number,
          ),
        );
      case String value:
        if (_isRelational(effective)) {
          final number = stringToNumber(value);
          return set.nodes.any(
            (node) => _compareNumbers(
              effective,
              stringToNumber(node.stringValue),
              number,
            ),
          );
        }
        return set.nodes.any(
          (node) => effective == ComparisonOperator.equals
              ? node.stringValue == value
              : node.stringValue != value,
        );
      default:
        throw XPathException("Cannot compare $other.");
    }
  }

  if (_isRelational(operator)) {
    return _compareNumbers(operator, toXPathNumber(a), toXPathNumber(b));
  }

  if (a is bool || b is bool) {
    return _compareBooleans(operator, toXPathBoolean(a), toXPathBoolean(b));
  }

  if (a is double || b is double || a is int || b is int) {
    return _compareNumbers(operator, toXPathNumber(a), toXPathNumber(b));
  }

  final equal = toXPathString(a) == toXPathString(b);
  return operator == ComparisonOperator.equals ? equal : !equal;
}

bool _isRelational(ComparisonOperator operator) =>
    operator != ComparisonOperator.equals &&
    operator != ComparisonOperator.notEquals;

ComparisonOperator _swap(ComparisonOperator operator) => switch (operator) {
  ComparisonOperator.less => ComparisonOperator.greater,
  ComparisonOperator.lessOrEqual => ComparisonOperator.greaterOrEqual,
  ComparisonOperator.greater => ComparisonOperator.less,
  ComparisonOperator.greaterOrEqual => ComparisonOperator.lessOrEqual,
  _ => operator,
};

bool _compareNumbers(ComparisonOperator operator, double a, double b) =>
    switch (operator) {
      ComparisonOperator.equals => a == b,
      ComparisonOperator.notEquals => a != b,
      ComparisonOperator.less => a < b,
      ComparisonOperator.lessOrEqual => a <= b,
      ComparisonOperator.greater => a > b,
      ComparisonOperator.greaterOrEqual => a >= b,
    };

bool _compareBooleans(ComparisonOperator operator, bool a, bool b) {
  if (_isRelational(operator)) {
    return _compareNumbers(operator, a ? 1 : 0, b ? 1 : 0);
  }

  return operator == ComparisonOperator.equals ? a == b : a != b;
}

enum ArithmeticOperator { plus, minus, multiply, div, mod }

class ArithmeticExpression extends Expression {
  final ArithmeticOperator operator;
  final Expression left, right;

  const ArithmeticExpression(this.operator, this.left, this.right);

  @override
  Object evaluate(XPathContext context) {
    final a = left.evaluateNumber(context);
    final b = right.evaluateNumber(context);

    return switch (operator) {
      ArithmeticOperator.plus => a + b,
      ArithmeticOperator.minus => a - b,
      ArithmeticOperator.multiply => a * b,
      ArithmeticOperator.div => a / b,
      ArithmeticOperator.mod => a.remainder(b),
    };
  }
}

class NegateExpression extends Expression {
  final Expression operand;

  const NegateExpression(this.operand);

  @override
  Object evaluate(XPathContext context) => -operand.evaluateNumber(context);
}

class UnionExpression extends Expression {
  final Expression left, right;

  const UnionExpression(this.left, this.right);

  @override
  Object evaluate(XPathContext context) {
    final a = left.evaluateNodeSet(context);
    final b = right.evaluateNodeSet(context);

    if (a.isEmpty) return b;
    if (b.isEmpty) return a;

    return NodeSet.unordered([...a.nodes, ...b.nodes]);
  }
}

class LiteralExpression extends Expression {
  final String value;

  const LiteralExpression(this.value);

  @override
  Object evaluate(XPathContext context) => value;
}

class NumberExpression extends Expression {
  final double value;

  const NumberExpression(this.value);

  @override
  Object evaluate(XPathContext context) => value;
}

class VariableExpression extends Expression {
  final QName name;

  const VariableExpression(this.name);

  @override
  Object evaluate(XPathContext context) => context.environment.variable(name);
}

class FunctionCallExpression extends Expression {
  final QName name;
  final List<Expression> arguments;

  const FunctionCallExpression(this.name, this.arguments);

  @override
  Object evaluate(XPathContext context) =>
      context.environment.callFunction(name, arguments, context);

  @override
  String toString() => "$name(${arguments.join(", ")})";
}

/// Primary expression with predicates.
class FilterExpression extends Expression {
  final Expression primary;
  final List<Expression> predicates;

  const FilterExpression(this.primary, this.predicates);

  @override
  Object evaluate(XPathContext context) {
    var nodes = primary.evaluateNodeSet(context).nodes;
    for (final predicate in predicates) {
      nodes = applyPredicate(predicate, nodes, context);
    }

    return NodeSet(nodes);
  }
}

/// Filter expression followed by relative location path.
class PathExpression extends Expression {
  final Expression filter;
  final List<Step> steps;

  const PathExpression(this.filter, this.steps);

  @override
  Object evaluate(XPathContext context) =>
      evaluateSteps(filter.evaluateNodeSet(context), steps, context);
}

class LocationPath extends Expression {
  final bool absolute;
  final List<Step> steps;

  const LocationPath(this.absolute, this.steps);

  @override
  Object evaluate(XPathContext context) {
    final start = absolute ? context.node.root : context.node;
    return evaluateSteps(NodeSet([start]), steps, context);
  }

  @override
  String toString() => "${absolute ? "/" : ""}${steps.join("/")}";
}

NodeSet evaluateSteps(NodeSet input, List<Step> steps, XPathContext context) {
  var current = input;

  for (final step in steps) {
    if (current.isEmpty) return current;

    if (current.nodes.length == 1) {
      current = NodeSet(step.select(current.nodes.single, context));
      continue;
    }

    final result = <XNode>[];
    for (final node in current.nodes) {
      result.addAll(step.select(node, context));
    }

    current = NodeSet.unordered(result);
  }

  return current;
}

/// Filters [nodes] in axis order by [predicate].
List<XNode> applyPredicate(
  Expression predicate,
  List<XNode> nodes,
  XPathContext context,
) {
  final result = <XNode>[];
  final size = nodes.length;

  for (var i = 0; i < size; i++) {
    final nodeContext = context.withNode(nodes[i], i + 1, size);
    final value = predicate.evaluate(nodeContext);

    final keep = (value is double)
        ? value == i + 1
        : (value is int ? value == i + 1 : toXPathBoolean(value));
    if (keep) result.add(nodes[i]);
  }

  return result;
}

enum Axis {
  ancestor(reverse: true),
  ancestorOrSelf(reverse: true),
  attribute,
  child,
  descendant,
  descendantOrSelf,
  following,
  followingSibling,
  namespace,
  parent,
  preceding(reverse: true),
  precedingSibling(reverse: true),
  self
  ;

  final bool reverse;

  const Axis({this.reverse = false});

  static Axis? fromName(String name) => switch (name) {
    "ancestor" => ancestor,
    "ancestor-or-self" => ancestorOrSelf,
    "attribute" => attribute,
    "child" => child,
    "descendant" => descendant,
    "descendant-or-self" => descendantOrSelf,
    "following" => following,
    "following-sibling" => followingSibling,
    "namespace" => namespace,
    "parent" => parent,
    "preceding" => preceding,
    "preceding-sibling" => precedingSibling,
    "self" => self,
    _ => null,
  };
}

/// Node test of a step.
sealed class NodeTest {
  const NodeTest();

  bool matches(XNode node, Axis axis);
}

/// `*`, `prefix:*` or QName test.
class NameTest extends NodeTest {
  /// `null` matches any namespace (`*`).
  final String? namespace;
  final bool anyNamespace;

  /// `null` matches any local name.
  final String? local;

  const NameTest(this.namespace, this.local, {this.anyNamespace = false});

  @override
  bool matches(XNode node, Axis axis) {
    final QName name;
    switch (node) {
      case XElement element
          when axis != Axis.attribute && axis != Axis.namespace:
        name = element.name;
      case XAttribute attribute when axis == Axis.attribute:
        name = attribute.name;
      case XNamespace ns when axis == Axis.namespace:
        return local == null || ns.prefix == local;
      default:
        return false;
    }

    if (!anyNamespace && name.namespace != namespace) return false;

    return local == null || name.local == local;
  }

  @override
  String toString() => anyNamespace
      ? "*"
      : "${namespace == null ? "" : "{$namespace}"}${local ?? "*"}";
}

enum NodeType { node, text, comment, processingInstruction }

class NodeTypeTest extends NodeTest {
  final NodeType type;

  /// Target of `processing-instruction('target')`.
  final String? target;

  const NodeTypeTest(this.type, [this.target]);

  @override
  bool matches(XNode node, Axis axis) => switch (type) {
    NodeType.node => true,
    NodeType.text => node is XText,
    NodeType.comment => node is XComment,
    NodeType.processingInstruction =>
      node is XProcessingInstruction &&
          (target == null || node.target == target),
  };

  @override
  String toString() => "${type.name}()";
}

class Step {
  final Axis axis;
  final NodeTest test;
  final List<Expression> predicates;

  const Step(this.axis, this.test, this.predicates);

  /// Selects nodes of this step from the context [node] in document order.
  List<XNode> select(XNode node, XPathContext context) {
    var nodes = <XNode>[];
    for (final candidate in axisNodes(axis, node)) {
      if (test.matches(candidate, axis)) nodes.add(candidate);
    }

    for (final predicate in predicates) {
      nodes = applyPredicate(predicate, nodes, context);
    }

    return axis.reverse ? nodes.reversed.toList() : nodes;
  }

  @override
  String toString() =>
      "${axis.name}::$test${predicates.map((p) => "[$p]").join()}";
}

/// Nodes of the [axis] from the [node] in axis order.
Iterable<XNode> axisNodes(Axis axis, XNode node) sync* {
  switch (axis) {
    case Axis.child:
      if (node is XParent) yield* node.children;

    case Axis.attribute:
      if (node is XElement) yield* node.attributes;

    case Axis.self:
      yield node;

    case Axis.parent:
      final parent = node.parent;
      if (parent != null) yield parent;

    case Axis.ancestor:
      for (var p = node.parent; p != null; p = p.parent) {
        yield p;
      }

    case Axis.ancestorOrSelf:
      for (XNode? p = node; p != null; p = p.parent) {
        yield p;
      }

    case Axis.descendant:
      if (node is XParent) yield* _descendants(node);

    case Axis.descendantOrSelf:
      yield node;
      if (node is XParent) yield* _descendants(node);

    case Axis.followingSibling:
      if (node is XAttribute || node is XNamespace) return;
      final parent = node.parent;
      if (parent is XParent) {
        final siblings = parent.children;
        for (var i = siblings.indexOf(node) + 1; i < siblings.length; i++) {
          yield siblings[i];
        }
      }

    case Axis.precedingSibling:
      if (node is XAttribute || node is XNamespace) return;
      final parent = node.parent;
      if (parent is XParent) {
        final siblings = parent.children;
        for (var i = siblings.indexOf(node) - 1; i >= 0; i--) {
          yield siblings[i];
        }
      }

    case Axis.following:
      XNode current = node;
      if (node is XAttribute || node is XNamespace) {
        current = node.parent!;
        if (current is XParent) yield* _descendants(current);
      }
      for (XNode? n = current; n != null; n = n.parent) {
        final parent = n.parent;
        if (parent is XParent) {
          final siblings = parent.children;
          for (var i = siblings.indexOf(n) + 1; i < siblings.length; i++) {
            yield siblings[i];
            final sibling = siblings[i];
            if (sibling is XParent) yield* _descendants(sibling);
          }
        }
      }

    case Axis.preceding:
      XNode current = node;
      if (node is XAttribute || node is XNamespace) current = node.parent!;
      for (XNode? n = current; n != null; n = n.parent) {
        final parent = n.parent;
        if (parent is XParent) {
          final siblings = parent.children;
          for (var i = siblings.indexOf(n) - 1; i >= 0; i--) {
            final sibling = siblings[i];
            if (sibling is XParent) {
              yield* _descendants(sibling).toList().reversed;
            }
            yield sibling;
          }
        }
      }

    case Axis.namespace:
      if (node is XElement) {
        final namespaces = {...node.inScopeNamespaces, "xml": xmlNamespace};
        for (final MapEntry(key: prefix, value: uri) in namespaces.entries) {
          yield XNamespace(node.tree, prefix, uri)..parent = node;
        }
      }
  }
}

Iterable<XNode> _descendants(XParent node) sync* {
  for (final child in node.children) {
    yield child;
    if (child is XParent) yield* _descendants(child);
  }
}
