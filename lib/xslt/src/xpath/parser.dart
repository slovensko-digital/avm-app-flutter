import '../errors.dart';
import '../nodes.dart';
import 'ast.dart';
import 'lexer.dart';

/// Resolves namespace prefix to URI, `null` if the prefix is not declared.
typedef NamespaceResolver = String? Function(String prefix);

/// Parses XPath 1.0 expressions.
class XPathParser {
  final NamespaceResolver resolveNamespace;

  /// Namespace of unprefixed element names (XSLT 2.0
  /// `xpath-default-namespace`), no namespace in XPath 1.0.
  final String? defaultElementNamespace;

  late List<Token> _tokens;
  late String _expression;
  var _index = 0;

  XPathParser(this.resolveNamespace, {this.defaultElementNamespace});

  Expression parse(String expression) {
    _expression = expression;
    _tokens = tokenize(expression);
    _index = 0;

    final result = _orExpression();
    if (_peek.type != TokenType.end) {
      throw XPathException("Unexpected '${_peek.value}' in '$expression'.");
    }

    return result;
  }

  Token get _peek => _tokens[_index];

  Token _next() => _tokens[_index++];

  bool _accept(TokenType type) {
    if (_peek.type == type) {
      _index++;
      return true;
    }
    return false;
  }

  Token _expect(TokenType type) {
    if (_peek.type != type) {
      throw XPathException(
        "Expected $type instead of '${_peek.value}' in '$_expression'.",
      );
    }
    return _next();
  }

  Expression _orExpression() {
    var left = _andExpression();
    while (_accept(TokenType.or)) {
      left = OrExpression(left, _andExpression());
    }
    return left;
  }

  Expression _andExpression() {
    var left = _equalityExpression();
    while (_accept(TokenType.and)) {
      left = AndExpression(left, _equalityExpression());
    }
    return left;
  }

  Expression _equalityExpression() {
    var left = _relationalExpression();
    while (true) {
      if (_accept(TokenType.equals)) {
        left = ComparisonExpression(
          ComparisonOperator.equals,
          left,
          _relationalExpression(),
        );
      } else if (_accept(TokenType.notEquals)) {
        left = ComparisonExpression(
          ComparisonOperator.notEquals,
          left,
          _relationalExpression(),
        );
      } else {
        return left;
      }
    }
  }

  Expression _relationalExpression() {
    var left = _additiveExpression();
    while (true) {
      final operator = switch (_peek.type) {
        TokenType.less => ComparisonOperator.less,
        TokenType.lessOrEqual => ComparisonOperator.lessOrEqual,
        TokenType.greater => ComparisonOperator.greater,
        TokenType.greaterOrEqual => ComparisonOperator.greaterOrEqual,
        _ => null,
      };
      if (operator == null) return left;

      _next();
      left = ComparisonExpression(operator, left, _additiveExpression());
    }
  }

  Expression _additiveExpression() {
    var left = _multiplicativeExpression();
    while (true) {
      if (_accept(TokenType.plus)) {
        left = ArithmeticExpression(
          ArithmeticOperator.plus,
          left,
          _multiplicativeExpression(),
        );
      } else if (_accept(TokenType.minus)) {
        left = ArithmeticExpression(
          ArithmeticOperator.minus,
          left,
          _multiplicativeExpression(),
        );
      } else {
        return left;
      }
    }
  }

  Expression _multiplicativeExpression() {
    var left = _unaryExpression();
    while (true) {
      final operator = switch (_peek.type) {
        TokenType.multiply => ArithmeticOperator.multiply,
        TokenType.div => ArithmeticOperator.div,
        TokenType.mod => ArithmeticOperator.mod,
        _ => null,
      };
      if (operator == null) return left;

      _next();
      left = ArithmeticExpression(operator, left, _unaryExpression());
    }
  }

  Expression _unaryExpression() {
    if (_accept(TokenType.minus)) {
      return NegateExpression(_unaryExpression());
    }
    return _unionExpression();
  }

  Expression _unionExpression() {
    var left = _pathExpression();
    while (_accept(TokenType.pipe)) {
      left = UnionExpression(left, _pathExpression());
    }
    return left;
  }

  Expression _pathExpression() {
    final type = _peek.type;
    final isPrimary =
        type == TokenType.variable ||
        type == TokenType.leftParen ||
        type == TokenType.literal ||
        type == TokenType.number ||
        type == TokenType.functionName;

    if (!isPrimary) {
      return _locationPath();
    }

    final primary = _primaryExpression();
    final predicates = _predicates();
    final filter = predicates.isEmpty
        ? primary
        : FilterExpression(primary, predicates);

    if (_peek.type == TokenType.slash || _peek.type == TokenType.doubleSlash) {
      final steps = <Step>[];
      if (_next().type == TokenType.doubleSlash) {
        steps.add(_descendantOrSelfStep);
      }
      steps.addAll(_relativeLocationPath());
      return PathExpression(filter, steps);
    }

    return filter;
  }

  static const _descendantOrSelfStep = Step(
    Axis.descendantOrSelf,
    NodeTypeTest(NodeType.node),
    [],
  );

  Expression _locationPath() {
    if (_accept(TokenType.slash)) {
      if (_isStepStart(_peek.type)) {
        return LocationPath(true, _relativeLocationPath());
      }
      return const LocationPath(true, []);
    }

    if (_accept(TokenType.doubleSlash)) {
      return LocationPath(true, [
        _descendantOrSelfStep,
        ..._relativeLocationPath(),
      ]);
    }

    return LocationPath(false, _relativeLocationPath());
  }

  static bool _isStepStart(TokenType type) =>
      type == TokenType.nameTest ||
      type == TokenType.nodeType ||
      type == TokenType.axisName ||
      type == TokenType.at ||
      type == TokenType.dot ||
      type == TokenType.dotDot;

  List<Step> _relativeLocationPath() {
    final steps = [_step()];
    while (true) {
      if (_accept(TokenType.slash)) {
        steps.add(_step());
      } else if (_accept(TokenType.doubleSlash)) {
        steps.add(_descendantOrSelfStep);
        steps.add(_step());
      } else {
        return steps;
      }
    }
  }

  Step _step() {
    if (_accept(TokenType.dot)) {
      return const Step(Axis.self, NodeTypeTest(NodeType.node), []);
    }
    if (_accept(TokenType.dotDot)) {
      return const Step(Axis.parent, NodeTypeTest(NodeType.node), []);
    }

    var axis = Axis.child;
    if (_accept(TokenType.at)) {
      axis = Axis.attribute;
    } else if (_peek.type == TokenType.axisName) {
      final name = _next().value;
      axis =
          Axis.fromName(name) ??
          (throw XPathException("Unknown axis '$name' in '$_expression'."));
      _expect(TokenType.colonColon);
    }

    final test = _nodeTest(axis);
    return Step(axis, test, _predicates());
  }

  NodeTest _nodeTest(Axis axis) {
    final token = _next();

    switch (token.type) {
      case TokenType.nameTest:
        return parseNameTest(
          token.value,
          axis != Axis.attribute && axis != Axis.namespace,
        );

      case TokenType.nodeType:
        _expect(TokenType.leftParen);
        final test = switch (token.value) {
          "node" => const NodeTypeTest(NodeType.node),
          "text" => const NodeTypeTest(NodeType.text),
          "comment" => const NodeTypeTest(NodeType.comment),
          _ =>
            _peek.type == TokenType.literal
                ? NodeTypeTest(NodeType.processingInstruction, _next().value)
                : const NodeTypeTest(NodeType.processingInstruction),
        };
        _expect(TokenType.rightParen);
        return test;

      default:
        throw XPathException(
          "Expected node test instead of '${token.value}' in '$_expression'.",
        );
    }
  }

  /// Parses `*`, `prefix:*` or QName name test. Unprefixed names of
  /// elements may have default namespace.
  NameTest parseNameTest(String value, bool isElement) {
    if (value == "*") {
      return const NameTest(null, null, anyNamespace: true);
    }

    final colon = value.indexOf(":");
    if (colon < 0) {
      return NameTest(isElement ? defaultElementNamespace : null, value);
    }

    final prefix = value.substring(0, colon);
    final local = value.substring(colon + 1);
    final namespace = _resolvePrefix(prefix);

    return NameTest(namespace, local == "*" ? null : local);
  }

  String _resolvePrefix(String prefix) {
    if (prefix == "xml") return xmlNamespace;

    return resolveNamespace(prefix) ??
        (throw XPathException(
          "Undeclared namespace prefix '$prefix' in '$_expression'.",
        ));
  }

  /// Resolves QName of variable or function (unprefixed has no namespace).
  QName resolveQName(String qname) {
    final colon = qname.indexOf(":");
    if (colon < 0) return QName(null, qname);

    return QName(
      _resolvePrefix(qname.substring(0, colon)),
      qname.substring(colon + 1),
    );
  }

  List<Expression> _predicates() {
    final predicates = <Expression>[];
    while (_accept(TokenType.leftBracket)) {
      predicates.add(_orExpression());
      _expect(TokenType.rightBracket);
    }
    return predicates;
  }

  Expression _primaryExpression() {
    final token = _next();

    switch (token.type) {
      case TokenType.variable:
        return VariableExpression(resolveQName(token.value));

      case TokenType.leftParen:
        final expression = _orExpression();
        _expect(TokenType.rightParen);
        return expression;

      case TokenType.literal:
        return LiteralExpression(token.value);

      case TokenType.number:
        return NumberExpression(double.parse(token.value));

      case TokenType.functionName:
        _expect(TokenType.leftParen);
        final arguments = <Expression>[];
        if (!_accept(TokenType.rightParen)) {
          do {
            arguments.add(_orExpression());
          } while (_accept(TokenType.comma));
          _expect(TokenType.rightParen);
        }
        return FunctionCallExpression(resolveQName(token.value), arguments);

      default:
        throw XPathException("Unexpected '${token.value}' in '$_expression'.");
    }
  }
}
