import '../errors.dart';

enum TokenType {
  leftParen,
  rightParen,
  leftBracket,
  rightBracket,
  dot,
  dotDot,
  at,
  comma,
  colonColon,
  slash,
  doubleSlash,
  pipe,
  plus,
  minus,
  equals,
  notEquals,
  less,
  lessOrEqual,
  greater,
  greaterOrEqual,
  multiply,
  and,
  or,
  mod,
  div,

  /// `*`, `prefix:*`, `name` or `prefix:name`
  nameTest,
  nodeType,
  functionName,
  axisName,
  literal,
  number,
  variable,
  end,
}

class Token {
  final TokenType type;
  final String value;
  final int position;

  const Token(this.type, this.value, this.position);

  @override
  String toString() => "$type($value)";
}

/// Tokenizes XPath 1.0 expression.
List<Token> tokenize(String expression) {
  final tokens = <Token>[];
  var i = 0;

  bool precedingIsOperand() {
    if (tokens.isEmpty) return false;

    return switch (tokens.last.type) {
      TokenType.at ||
      TokenType.colonColon ||
      TokenType.leftParen ||
      TokenType.leftBracket ||
      TokenType.comma ||
      TokenType.slash ||
      TokenType.doubleSlash ||
      TokenType.pipe ||
      TokenType.plus ||
      TokenType.minus ||
      TokenType.equals ||
      TokenType.notEquals ||
      TokenType.less ||
      TokenType.lessOrEqual ||
      TokenType.greater ||
      TokenType.greaterOrEqual ||
      TokenType.multiply ||
      TokenType.and ||
      TokenType.or ||
      TokenType.mod ||
      TokenType.div => false,
      _ => true,
    };
  }

  void add(TokenType type, String value, int start) {
    tokens.add(Token(type, value, start));
  }

  while (i < expression.length) {
    final c = expression[i];
    final start = i;

    if (_isWhitespace(c)) {
      i++;
      continue;
    }

    switch (c) {
      case "(":
        add(TokenType.leftParen, c, start);
        i++;
        continue;
      case ")":
        add(TokenType.rightParen, c, start);
        i++;
        continue;
      case "[":
        add(TokenType.leftBracket, c, start);
        i++;
        continue;
      case "]":
        add(TokenType.rightBracket, c, start);
        i++;
        continue;
      case "@":
        add(TokenType.at, c, start);
        i++;
        continue;
      case ",":
        add(TokenType.comma, c, start);
        i++;
        continue;
      case "|":
        add(TokenType.pipe, c, start);
        i++;
        continue;
      case "+":
        add(TokenType.plus, c, start);
        i++;
        continue;
      case "-":
        add(TokenType.minus, c, start);
        i++;
        continue;
      case "=":
        add(TokenType.equals, c, start);
        i++;
        continue;
      case "!":
        if (_at(expression, i + 1) == "=") {
          add(TokenType.notEquals, "!=", start);
          i += 2;
          continue;
        }
        throw XPathException("Unexpected '!' in '$expression'.");
      case "<":
        if (_at(expression, i + 1) == "=") {
          add(TokenType.lessOrEqual, "<=", start);
          i += 2;
        } else {
          add(TokenType.less, c, start);
          i++;
        }
        continue;
      case ">":
        if (_at(expression, i + 1) == "=") {
          add(TokenType.greaterOrEqual, ">=", start);
          i += 2;
        } else {
          add(TokenType.greater, c, start);
          i++;
        }
        continue;
      case "/":
        if (_at(expression, i + 1) == "/") {
          add(TokenType.doubleSlash, "//", start);
          i += 2;
        } else {
          add(TokenType.slash, c, start);
          i++;
        }
        continue;
      case ":":
        if (_at(expression, i + 1) == ":") {
          add(TokenType.colonColon, "::", start);
          i += 2;
          continue;
        }
        throw XPathException("Unexpected ':' in '$expression'.");
      case "\"" || "'":
        final end = expression.indexOf(c, i + 1);
        if (end < 0) {
          throw XPathException("Unterminated literal in '$expression'.");
        }
        add(TokenType.literal, expression.substring(i + 1, end), start);
        i = end + 1;
        continue;
      case "\$":
        i++;
        final name = _readQName(expression, i);
        if (name == null) {
          throw XPathException("Invalid variable reference in '$expression'.");
        }
        add(TokenType.variable, name, start);
        i += name.length;
        continue;
      case "*":
        add(
          precedingIsOperand() ? TokenType.multiply : TokenType.nameTest,
          c,
          start,
        );
        i++;
        continue;
      case ".":
        if (_at(expression, i + 1) == ".") {
          add(TokenType.dotDot, "..", start);
          i += 2;
          continue;
        }
        if (_isDigit(_at(expression, i + 1))) {
          final number = _readNumber(expression, i);
          add(TokenType.number, number, start);
          i += number.length;
          continue;
        }
        add(TokenType.dot, c, start);
        i++;
        continue;
    }

    if (_isDigit(c)) {
      final number = _readNumber(expression, i);
      add(TokenType.number, number, start);
      i += number.length;
      continue;
    }

    final ncName = _readNCName(expression, i);
    if (ncName == null) {
      throw XPathException("Unexpected '$c' in '$expression'.");
    }

    if (precedingIsOperand()) {
      final type = switch (ncName) {
        "and" => TokenType.and,
        "or" => TokenType.or,
        "mod" => TokenType.mod,
        "div" => TokenType.div,
        _ => throw XPathException(
          "Expected operator instead of '$ncName' in '$expression'.",
        ),
      };
      add(type, ncName, start);
      i += ncName.length;
      continue;
    }

    var name = ncName;
    i += ncName.length;

    // prefix:* or prefix:local
    if (_at(expression, i) == ":" && _at(expression, i + 1) != ":") {
      if (_at(expression, i + 1) == "*") {
        add(TokenType.nameTest, "$name:*", start);
        i += 2;
        continue;
      }

      final local = _readNCName(expression, i + 1);
      if (local == null) {
        throw XPathException("Invalid QName in '$expression'.");
      }
      name = "$name:$local";
      i += 1 + local.length;
    }

    final next = _nextNonWhitespace(expression, i);
    if (next == "(") {
      final type = switch (name) {
        "comment" ||
        "text" ||
        "processing-instruction" ||
        "node" => TokenType.nodeType,
        _ => TokenType.functionName,
      };
      add(type, name, start);
    } else if (next == ":" &&
        _at(expression, _skipWhitespace(expression, i) + 1) == ":") {
      add(TokenType.axisName, name, start);
    } else {
      add(TokenType.nameTest, name, start);
    }
  }

  tokens.add(Token(TokenType.end, "", expression.length));
  return tokens;
}

String _at(String s, int i) => i < s.length ? s[i] : "";

bool _isWhitespace(String c) => c == " " || c == "\t" || c == "\n" || c == "\r";

bool _isDigit(String c) =>
    c.isNotEmpty && c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;

int _skipWhitespace(String s, int i) {
  while (i < s.length && _isWhitespace(s[i])) {
    i++;
  }
  return i;
}

String _nextNonWhitespace(String s, int i) => _at(s, _skipWhitespace(s, i));

String _readNumber(String s, int i) {
  final start = i;
  while (_isDigit(_at(s, i))) {
    i++;
  }
  if (_at(s, i) == ".") {
    i++;
    while (_isDigit(_at(s, i))) {
      i++;
    }
  }
  return s.substring(start, i);
}

String? _readQName(String s, int i) {
  final prefix = _readNCName(s, i);
  if (prefix == null) return null;

  if (_at(s, i + prefix.length) == ":") {
    final local = _readNCName(s, i + prefix.length + 1);
    if (local != null) return "$prefix:$local";
  }

  return prefix;
}

String? _readNCName(String s, int i) {
  if (i >= s.length || !isNameStartChar(s.codeUnitAt(i))) return null;

  final start = i;
  i++;
  while (i < s.length && isNameChar(s.codeUnitAt(i))) {
    i++;
  }
  return s.substring(start, i);
}

bool isNameStartChar(int c) =>
    (c >= 0x41 && c <= 0x5A) ||
    (c >= 0x61 && c <= 0x7A) ||
    c == 0x5F ||
    c >= 0xC0;

bool isNameChar(int c) =>
    isNameStartChar(c) ||
    (c >= 0x30 && c <= 0x39) ||
    c == 0x2D ||
    c == 0x2E ||
    c == 0xB7;
