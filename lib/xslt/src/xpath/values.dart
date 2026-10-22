import '../nodes.dart';

/// XPath node-set - nodes in document order without duplicates.
class NodeSet {
  final List<XNode> nodes;

  const NodeSet(this.nodes);

  static const empty = NodeSet([]);

  /// Creates node-set from [nodes] in any order, possibly with duplicates.
  factory NodeSet.unordered(Iterable<XNode> nodes) {
    final unique = nodes.toSet().toList()..sort((a, b) => a.compareTo(b));
    return NodeSet(unique);
  }

  bool get isEmpty => nodes.isEmpty;

  XNode? get first => nodes.isEmpty ? null : nodes.first;
}

/// Converts XPath value (node-set, string, number, boolean) to string.
String toXPathString(Object value) {
  return switch (value) {
    String s => s,
    NodeSet set => set.first?.stringValue ?? "",
    double d => numberToString(d),
    bool b => b ? "true" : "false",
    int i => numberToString(i.toDouble()),
    _ => throw ArgumentError.value(value, "value", "Not XPath value"),
  };
}

/// Converts XPath value to number.
double toXPathNumber(Object value) {
  return switch (value) {
    double d => d,
    int i => i.toDouble(),
    bool b => b ? 1 : 0,
    String s => stringToNumber(s),
    NodeSet set => stringToNumber(toXPathString(set)),
    _ => throw ArgumentError.value(value, "value", "Not XPath value"),
  };
}

/// Converts XPath value to boolean.
bool toXPathBoolean(Object value) {
  return switch (value) {
    bool b => b,
    double d => d != 0 && !d.isNaN,
    int i => i != 0,
    String s => s.isNotEmpty,
    NodeSet set => !set.isEmpty,
    _ => throw ArgumentError.value(value, "value", "Not XPath value"),
  };
}

final _numberPattern = RegExp(r"^\s*-?(\d+(\.\d*)?|\.\d+)\s*$");

/// Converts string to number according to XPath 1.0 - only decimal notation
/// with optional minus sign and whitespace around, NaN otherwise.
double stringToNumber(String s) {
  if (!_numberPattern.hasMatch(s)) return double.nan;

  return double.parse(s.trim());
}

/// Converts number to string according to XPath 1.0 - without exponent.
String numberToString(double d) {
  if (d.isNaN) return "NaN";
  if (d.isInfinite) return d > 0 ? "Infinity" : "-Infinity";
  if (d == 0) return "0";

  if (d == d.truncateToDouble() && d.abs() < 1e15) {
    return d.toInt().toString();
  }

  final negative = d < 0;
  var s = d.abs().toString();

  final exponentIndex = s.indexOf("e");
  if (exponentIndex >= 0) {
    final exponent = int.parse(s.substring(exponentIndex + 1));
    var mantissa = s.substring(0, exponentIndex);
    final dot = mantissa.indexOf(".");
    var digits = mantissa.replaceFirst(".", "");
    var pointPosition = (dot < 0 ? mantissa.length : dot) + exponent;

    if (pointPosition <= 0) {
      s = "0.${"0" * -pointPosition}$digits";
    } else if (pointPosition >= digits.length) {
      s = digits + "0" * (pointPosition - digits.length);
    } else {
      s = "${digits.substring(0, pointPosition)}.${digits.substring(pointPosition)}";
    }
  }

  if (s.contains(".")) {
    s = s.replaceFirst(RegExp(r"0+$"), "");
    if (s.endsWith(".")) s = s.substring(0, s.length - 1);
  }

  return negative ? "-$s" : s;
}
