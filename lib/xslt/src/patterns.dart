import 'errors.dart';
import 'nodes.dart';
import 'xpath/ast.dart';
import 'xpath/values.dart';

/// XSLT pattern of `match` attribute - alternatives separated by `|`.
class Pattern {
  final List<PathPattern> alternatives;

  const Pattern(this.alternatives);

  /// Converts parsed XPath [expression] to pattern.
  factory Pattern.fromExpression(Expression expression, String source) {
    final alternatives = <PathPattern>[];

    void collect(Expression e) {
      if (e is UnionExpression) {
        collect(e.left);
        collect(e.right);
      } else {
        alternatives.add(PathPattern._fromExpression(e, source));
      }
    }

    collect(expression);
    return Pattern(alternatives);
  }

  bool matches(XNode node, XPathContext context) =>
      alternatives.any((alternative) => alternative.matches(node, context));
}

enum _Separator { parent, ancestor }

/// Single alternative of the pattern - steps matched from the right.
class PathPattern {
  final List<StepPattern> steps;

  /// Separator preceding each step, the first one applies to the anchor.
  final List<_Separator> _separators;

  /// Pattern is `/` or starts with `/`.
  final bool rootAnchored;

  /// `id()` or `key()` function the pattern starts with.
  final FunctionCallExpression? anchor;

  const PathPattern._(
    this.steps,
    this._separators,
    this.rootAnchored,
    this.anchor,
  );

  factory PathPattern._fromExpression(Expression expression, String source) {
    FunctionCallExpression? anchor;
    List<Step> pathSteps;
    var rootAnchored = false;

    switch (expression) {
      case LocationPath path:
        rootAnchored = path.absolute;
        pathSteps = path.steps;
      case PathExpression(filter: FunctionCallExpression call, :final steps)
          when _isAnchorFunction(call):
        anchor = call;
        pathSteps = steps;
      case FunctionCallExpression call when _isAnchorFunction(call):
        anchor = call;
        pathSteps = const [];
      default:
        throw XsltException("Invalid pattern '$source'.");
    }

    final steps = <StepPattern>[];
    final separators = <_Separator>[];
    var separator = _Separator.parent;

    for (final step in pathSteps) {
      if (step.axis == Axis.descendantOrSelf &&
          step.test is NodeTypeTest &&
          (step.test as NodeTypeTest).type == NodeType.node &&
          step.predicates.isEmpty) {
        separator = _Separator.ancestor;
        continue;
      }

      if (step.axis != Axis.child && step.axis != Axis.attribute) {
        throw XsltException("Invalid axis in pattern '$source'.");
      }

      steps.add(StepPattern(step.axis, step.test, step.predicates));
      separators.add(separator);
      separator = _Separator.parent;
    }

    // `//a` matches any `a` in a tree
    if (rootAnchored &&
        separators.isNotEmpty &&
        separators.first == _Separator.ancestor) {
      rootAnchored = false;
    }

    return PathPattern._(steps, separators, rootAnchored, anchor);
  }

  static bool _isAnchorFunction(FunctionCallExpression call) =>
      call.name.namespace == null &&
      (call.name.local == "id" || call.name.local == "key");

  /// Default priority according to XSLT 1.0 section 5.5.
  double get defaultPriority {
    if (anchor != null || steps.length != 1 || rootAnchored) {
      return 0.5;
    }

    final step = steps.single;
    if (step.predicates.isNotEmpty) return 0.5;

    return switch (step.test) {
      NameTest(anyNamespace: true) => -0.5,
      NameTest(local: null) => -0.25,
      NameTest() => 0,
      NodeTypeTest(type: NodeType.processingInstruction, target: _?) => 0,
      NodeTypeTest() => -0.5,
    };
  }

  /// The name test of the last step, if it matches elements of single name.
  QName? get elementName {
    if (steps.isEmpty) return null;

    final step = steps.last;
    final test = step.test;
    if (step.axis == Axis.child &&
        test is NameTest &&
        !test.anyNamespace &&
        test.local != null) {
      return QName(test.namespace, test.local!);
    }

    return null;
  }

  bool matches(XNode node, XPathContext context) {
    if (steps.isEmpty) {
      if (anchor != null) return _matchesAnchor(node, context);
      return rootAnchored && node is XRoot;
    }

    return _matchStep(steps.length - 1, node, context);
  }

  bool _matchStep(int index, XNode node, XPathContext context) {
    if (!steps[index].matches(node, context)) return false;

    final parent = node.parent;
    final separator = _separators[index];

    if (index == 0) {
      if (anchor != null) {
        return _matchesAncestors(
          parent,
          separator,
          (n) => _matchesAnchor(n, context),
        );
      }
      if (rootAnchored) {
        return parent is XRoot;
      }
      return parent != null;
    }

    return _matchesAncestors(
      parent,
      separator,
      (n) => _matchStep(index - 1, n, context),
    );
  }

  static bool _matchesAncestors(
    XNode? parent,
    _Separator separator,
    bool Function(XNode node) matches,
  ) {
    if (parent == null) return false;
    if (separator == _Separator.parent) return matches(parent);

    for (
      XNode? ancestor = parent;
      ancestor != null;
      ancestor = ancestor.parent
    ) {
      if (matches(ancestor)) return true;
    }
    return false;
  }

  bool _matchesAnchor(XNode node, XPathContext context) {
    final value = anchor!.evaluate(context.withNode(node, 1, 1));
    return value is NodeSet && value.nodes.contains(node);
  }
}

class StepPattern {
  final Axis axis;
  final NodeTest test;
  final List<Expression> predicates;

  const StepPattern(this.axis, this.test, this.predicates);

  bool matches(XNode node, XPathContext context) {
    if (axis == Axis.attribute) {
      if (node is! XAttribute) return false;
    } else if (node is XAttribute || node is XNamespace || node is XRoot) {
      return false;
    }

    if (!test.matches(node, axis)) return false;
    if (predicates.isEmpty) return true;

    final parent = node.parent;
    if (parent == null) return false;

    // predicates are evaluated with positions among siblings matching the test
    var candidates = <XNode>[
      for (final candidate in axisNodes(axis, parent))
        if (test.matches(candidate, axis)) candidate,
    ];
    for (final predicate in predicates) {
      candidates = applyPredicate(predicate, candidates, context);
      if (!candidates.contains(node)) return false;
    }

    return true;
  }
}
