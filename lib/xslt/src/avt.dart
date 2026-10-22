import 'errors.dart';
import 'xpath/ast.dart';
import 'xpath/parser.dart';

/// Attribute value template - literal parts and `{expression}` parts.
class Avt {
  final List<Object> _parts;

  const Avt._(this._parts);

  /// Constant value without expressions.
  bool get isConstant => _parts.every((part) => part is String);

  factory Avt.parse(String value, XPathParser parser) {
    final parts = <Object>[];
    final literal = StringBuffer();
    var i = 0;

    while (i < value.length) {
      final c = value[i];

      if (c == "{") {
        if (i + 1 < value.length && value[i + 1] == "{") {
          literal.write("{");
          i += 2;
          continue;
        }

        // find closing brace outside of string literals
        var j = i + 1;
        String? quote;
        while (j < value.length) {
          final d = value[j];
          if (quote != null) {
            if (d == quote) quote = null;
          } else if (d == "'" || d == "\"") {
            quote = d;
          } else if (d == "}") {
            break;
          }
          j++;
        }
        if (j >= value.length) {
          throw XsltException("Unterminated expression in '$value'.");
        }

        if (literal.isNotEmpty) {
          parts.add(literal.toString());
          literal.clear();
        }
        parts.add(parser.parse(value.substring(i + 1, j)));
        i = j + 1;
        continue;
      }

      if (c == "}") {
        if (i + 1 < value.length && value[i + 1] == "}") {
          literal.write("}");
          i += 2;
          continue;
        }
        throw XsltException("Unescaped '}' in '$value'.");
      }

      literal.write(c);
      i++;
    }

    if (literal.isNotEmpty) parts.add(literal.toString());

    return Avt._(parts);
  }

  String evaluate(XPathContext context) {
    if (_parts.length == 1 && _parts.first is String) {
      return _parts.first as String;
    }

    final buffer = StringBuffer();
    for (final part in _parts) {
      buffer.write(part is Expression ? part.evaluateString(context) : part);
    }
    return buffer.toString();
  }
}
