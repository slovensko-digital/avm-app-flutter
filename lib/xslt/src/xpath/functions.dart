import '../errors.dart';
import '../nodes.dart';
import 'ast.dart';
import 'values.dart';

/// Implementation of XPath function.
typedef XPathFunction =
    Object Function(
      XPathContext context,
      List<Expression> arguments,
    );

/// XPath 1.0 core function library and few frequently used XPath 2.0 string
/// functions.
final Map<String, XPathFunction> coreFunctions = {
  // node-set functions
  "last": (context, args) {
    _arity("last", args, 0);
    return context.size.toDouble();
  },
  "position": (context, args) {
    _arity("position", args, 0);
    return context.position.toDouble();
  },
  "count": (context, args) {
    _arity("count", args, 1);
    return args[0].evaluateNodeSet(context).nodes.length.toDouble();
  },
  "id": (context, args) {
    _arity("id", args, 1);
    // documents are parsed without DTD, so there are no ID attributes
    return NodeSet.empty;
  },
  "local-name": (context, args) =>
      _nameOf(_optionalNode("local-name", context, args), _NamePart.local),
  "namespace-uri": (context, args) => _nameOf(
    _optionalNode("namespace-uri", context, args),
    _NamePart.namespace,
  ),
  "name": (context, args) =>
      _nameOf(_optionalNode("name", context, args), _NamePart.qualified),

  // string functions
  "string": (context, args) {
    _arity("string", args, 0, 1);
    return args.isEmpty
        ? context.node.stringValue
        : args[0].evaluateString(context);
  },
  "concat": (context, args) {
    if (args.length < 2) {
      throw const XPathException("concat() requires at least 2 arguments.");
    }
    return args.map((arg) => arg.evaluateString(context)).join();
  },
  "starts-with": (context, args) {
    _arity("starts-with", args, 2);
    return args[0]
        .evaluateString(context)
        .startsWith(args[1].evaluateString(context));
  },
  "ends-with": (context, args) {
    _arity("ends-with", args, 2);
    return args[0]
        .evaluateString(context)
        .endsWith(args[1].evaluateString(context));
  },
  "contains": (context, args) {
    _arity("contains", args, 2);
    return args[0]
        .evaluateString(context)
        .contains(args[1].evaluateString(context));
  },
  "substring-before": (context, args) {
    _arity("substring-before", args, 2);
    final s = args[0].evaluateString(context);
    final search = args[1].evaluateString(context);
    final index = s.indexOf(search);
    return index < 0 ? "" : s.substring(0, index);
  },
  "substring-after": (context, args) {
    _arity("substring-after", args, 2);
    final s = args[0].evaluateString(context);
    final search = args[1].evaluateString(context);
    final index = s.indexOf(search);
    return index < 0 ? "" : s.substring(index + search.length);
  },
  "substring": (context, args) {
    _arity("substring", args, 2, 3);
    final s = args[0].evaluateString(context);
    final start = args[1].evaluateNumber(context);
    final length = args.length > 2 ? args[2].evaluateNumber(context) : null;
    return substring(s, start, length);
  },
  "string-length": (context, args) {
    _arity("string-length", args, 0, 1);
    final s = args.isEmpty
        ? context.node.stringValue
        : args[0].evaluateString(context);
    return s.runes.length.toDouble();
  },
  "normalize-space": (context, args) {
    _arity("normalize-space", args, 0, 1);
    final s = args.isEmpty
        ? context.node.stringValue
        : args[0].evaluateString(context);
    return normalizeSpace(s);
  },
  "translate": (context, args) {
    _arity("translate", args, 3);
    return translate(
      args[0].evaluateString(context),
      args[1].evaluateString(context),
      args[2].evaluateString(context),
    );
  },
  "upper-case": (context, args) {
    _arity("upper-case", args, 1);
    return args[0].evaluateString(context).toUpperCase();
  },
  "lower-case": (context, args) {
    _arity("lower-case", args, 1);
    return args[0].evaluateString(context).toLowerCase();
  },
  "string-join": (context, args) {
    _arity("string-join", args, 1, 2);
    final value = args[0].evaluate(context);
    final separator = args.length > 1 ? args[1].evaluateString(context) : "";
    final items = value is NodeSet
        ? value.nodes.map((node) => node.stringValue)
        : [toXPathString(value)];
    return items.join(separator);
  },

  // boolean functions
  "boolean": (context, args) {
    _arity("boolean", args, 1);
    return args[0].evaluateBoolean(context);
  },
  "not": (context, args) {
    _arity("not", args, 1);
    return !args[0].evaluateBoolean(context);
  },
  "true": (context, args) {
    _arity("true", args, 0);
    return true;
  },
  "false": (context, args) {
    _arity("false", args, 0);
    return false;
  },
  "lang": (context, args) {
    _arity("lang", args, 1);
    final language = args[0].evaluateString(context).toLowerCase();
    for (XNode? node = context.node; node != null; node = node.parent) {
      if (node is XElement) {
        final lang = node.attribute(const QName(xmlNamespace, "lang"));
        if (lang != null) {
          final value = lang.value.toLowerCase();
          return value == language || value.startsWith("$language-");
        }
      }
    }
    return false;
  },
  "exists": (context, args) {
    _arity("exists", args, 1);
    final value = args[0].evaluate(context);
    return value is NodeSet ? !value.isEmpty : true;
  },
  "empty": (context, args) {
    _arity("empty", args, 1);
    final value = args[0].evaluate(context);
    return value is NodeSet ? value.isEmpty : false;
  },

  // number functions
  "number": (context, args) {
    _arity("number", args, 0, 1);
    return args.isEmpty
        ? stringToNumber(context.node.stringValue)
        : args[0].evaluateNumber(context);
  },
  "sum": (context, args) {
    _arity("sum", args, 1);
    return args[0]
        .evaluateNodeSet(context)
        .nodes
        .fold<double>(0, (sum, node) => sum + stringToNumber(node.stringValue));
  },
  "floor": (context, args) {
    _arity("floor", args, 1);
    final d = args[0].evaluateNumber(context);
    return d.isFinite ? d.floorToDouble() : d;
  },
  "ceiling": (context, args) {
    _arity("ceiling", args, 1);
    final d = args[0].evaluateNumber(context);
    return d.isFinite ? d.ceilToDouble() : d;
  },
  "round": (context, args) {
    _arity("round", args, 1);
    return round(args[0].evaluateNumber(context));
  },
  "abs": (context, args) {
    _arity("abs", args, 1);
    return args[0].evaluateNumber(context).abs();
  },
  "max": (context, args) => _aggregate("max", context, args, (a, b) => a > b),
  "min": (context, args) => _aggregate("min", context, args, (a, b) => a < b),
};

/// XPath 1.0 `substring()` with its rounding rules.
String substring(String s, double start, double? length) {
  final runes = s.runes.toList();
  final first = round(start);
  final last = length == null ? double.infinity : first + round(length);

  if (first.isNaN || last.isNaN) return "";

  final buffer = StringBuffer();
  for (var i = 0; i < runes.length; i++) {
    final position = i + 1;
    if (position >= first && position < last) {
      buffer.writeCharCode(runes[i]);
    }
  }
  return buffer.toString();
}

/// XPath 1.0 `round()` - rounds half up, keeps NaN, infinity and negative zero.
double round(double d) {
  if (!d.isFinite || d == 0) return d;
  if (d < 0 && d >= -0.5) return -0.0;

  return (d + 0.5).floorToDouble();
}

String normalizeSpace(String s) {
  return s
      .split(RegExp(r"[ \t\r\n]+"))
      .where((part) => part.isNotEmpty)
      .join(" ");
}

String translate(String s, String from, String to) {
  final fromRunes = from.runes.toList();
  final toRunes = to.runes.toList();
  final map = <int, int?>{};

  for (var i = 0; i < fromRunes.length; i++) {
    map.putIfAbsent(fromRunes[i], () => i < toRunes.length ? toRunes[i] : null);
  }

  final buffer = StringBuffer();
  for (final rune in s.runes) {
    if (map.containsKey(rune)) {
      final replacement = map[rune];
      if (replacement != null) buffer.writeCharCode(replacement);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

enum _NamePart { local, namespace, qualified }

XNode? _optionalNode(String name, XPathContext context, List<Expression> args) {
  _arity(name, args, 0, 1);
  return args.isEmpty ? context.node : args[0].evaluateNodeSet(context).first;
}

String _nameOf(XNode? node, _NamePart part) {
  final (QName name, String? prefix) = switch (node) {
    XElement element => (element.name, element.prefix),
    XAttribute attribute => (attribute.name, attribute.prefix),
    XProcessingInstruction pi => (QName(null, pi.target), null),
    XNamespace ns => (QName(null, ns.prefix), null),
    _ => (const QName(null, ""), null),
  };

  return switch (part) {
    _NamePart.local => name.local,
    _NamePart.namespace => node is XNamespace ? "" : (name.namespace ?? ""),
    _NamePart.qualified =>
      prefix == null || prefix.isEmpty ? name.local : "$prefix:${name.local}",
  };
}

double _aggregate(
  String name,
  XPathContext context,
  List<Expression> args,
  bool Function(double a, double b) isBetter,
) {
  if (args.isEmpty) {
    throw XPathException("$name() requires arguments.");
  }

  final values = <double>[];
  for (final arg in args) {
    final value = arg.evaluate(context);
    if (value is NodeSet) {
      values.addAll(
        value.nodes.map((node) => stringToNumber(node.stringValue)),
      );
    } else {
      values.add(toXPathNumber(value));
    }
  }

  if (values.isEmpty) return double.nan;
  if (values.any((value) => value.isNaN)) return double.nan;

  return values.reduce((a, b) => isBetter(b, a) ? b : a);
}

void _arity(String name, List<Expression> args, int min, [int? max]) {
  max ??= min;
  if (args.length < min || args.length > max) {
    throw XPathException("Wrong number of arguments of $name().");
  }
}
