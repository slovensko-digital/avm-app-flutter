import 'dart:typed_data' show ByteData;

import 'errors.dart';

/// Symbols of `xsl:decimal-format`.
class DecimalFormat {
  final String decimalSeparator;
  final String groupingSeparator;
  final String infinity;
  final String minusSign;
  final String nan;
  final String percent;
  final String perMille;
  final String zeroDigit;
  final String digit;
  final String patternSeparator;

  const DecimalFormat({
    this.decimalSeparator = ".",
    this.groupingSeparator = ",",
    this.infinity = "Infinity",
    this.minusSign = "-",
    this.nan = "NaN",
    this.percent = "%",
    this.perMille = "‰",
    this.zeroDigit = "0",
    this.digit = "#",
    this.patternSeparator = ";",
  });
}

/// Implements XSLT `format-number()` with JDK `DecimalFormat` pattern syntax.
String formatNumber(double value, String pattern, DecimalFormat format) {
  final subPatterns = _split(pattern, format.patternSeparator);
  if (subPatterns.isEmpty || subPatterns.length > 2) {
    throw XsltException("Invalid format-number() pattern '$pattern'.");
  }

  final positive = _SubPattern.parse(subPatterns[0], format);
  final negative = subPatterns.length > 1
      ? _SubPattern.parse(subPatterns[1], format)
      : null;

  if (value.isNaN) return format.nan;

  final isNegative = value < 0 || (value == 0 && value.isNegative);
  final sub = isNegative && negative != null ? negative : positive;
  final prefix = isNegative && negative == null
      ? "${format.minusSign}${positive.prefix}"
      : sub.prefix;
  final suffix = sub.suffix;

  if (value.isInfinite) return "$prefix${format.infinity}$suffix";

  final digits = _formatDigits(
    value.abs() * positive.multiplier,
    positive,
    format,
  );
  return "$prefix$digits$suffix";
}

List<String> _split(String pattern, String separator) {
  final parts = <String>[];
  final current = StringBuffer();
  var quoted = false;

  for (var i = 0; i < pattern.length; i++) {
    final c = pattern[i];
    if (c == "'") quoted = !quoted;
    if (!quoted && c == separator) {
      parts.add(current.toString());
      current.clear();
    } else {
      current.write(c);
    }
  }
  parts.add(current.toString());
  return parts;
}

class _SubPattern {
  final String prefix;
  final String suffix;
  final int minimumIntegerDigits;
  final int minimumFractionDigits;
  final int maximumFractionDigits;
  final int groupingSize;
  final int multiplier;

  const _SubPattern(
    this.prefix,
    this.suffix,
    this.minimumIntegerDigits,
    this.minimumFractionDigits,
    this.maximumFractionDigits,
    this.groupingSize,
    this.multiplier,
  );

  factory _SubPattern.parse(String pattern, DecimalFormat format) {
    bool isNumberChar(String c) =>
        c == format.digit ||
        c == format.zeroDigit ||
        c == format.groupingSeparator ||
        c == format.decimalSeparator;

    var start = 0;
    final prefix = StringBuffer();
    var quoted = false;
    while (start < pattern.length &&
        (quoted || !isNumberChar(pattern[start]))) {
      final c = pattern[start];
      if (c == "'") {
        quoted = !quoted;
      } else {
        prefix.write(c);
      }
      start++;
    }

    var end = start;
    while (end < pattern.length && isNumberChar(pattern[end])) {
      end++;
    }

    final suffix = StringBuffer();
    quoted = false;
    for (var i = end; i < pattern.length; i++) {
      final c = pattern[i];
      if (c == "'") {
        quoted = !quoted;
      } else {
        suffix.write(c);
      }
    }

    final number = pattern.substring(start, end);
    final decimal = number.indexOf(format.decimalSeparator);
    final integerPart = decimal < 0 ? number : number.substring(0, decimal);
    final fractionPart = decimal < 0 ? "" : number.substring(decimal + 1);

    final lastGrouping = integerPart.lastIndexOf(format.groupingSeparator);
    final groupingSize = lastGrouping < 0
        ? 0
        : integerPart.length - lastGrouping - 1;

    var multiplier = 1;
    final affixes = "$prefix$suffix";
    if (affixes.contains(format.percent)) multiplier = 100;
    if (affixes.contains(format.perMille)) multiplier = 1000;

    return _SubPattern(
      prefix.toString(),
      suffix.toString(),
      format.zeroDigit.allMatches(integerPart).length,
      format.zeroDigit.allMatches(fractionPart).length,
      format.zeroDigit.allMatches(fractionPart).length +
          format.digit.allMatches(fractionPart).length,
      groupingSize,
      multiplier,
    );
  }
}

String _formatDigits(double value, _SubPattern pattern, DecimalFormat format) {
  final (integer, fraction) = roundHalfEven(
    value,
    pattern.maximumFractionDigits,
  );

  var integerDigits = integer.toString();
  if (integerDigits == "0" && pattern.minimumIntegerDigits == 0) {
    integerDigits = "";
  }
  integerDigits = integerDigits.padLeft(pattern.minimumIntegerDigits, "0");

  var fractionDigits = fraction;
  while (fractionDigits.length > pattern.minimumFractionDigits &&
      fractionDigits.endsWith("0")) {
    fractionDigits = fractionDigits.substring(0, fractionDigits.length - 1);
  }

  if (pattern.groupingSize > 0 && integerDigits.length > pattern.groupingSize) {
    final groups = <String>[];
    var rest = integerDigits;
    while (rest.length > pattern.groupingSize) {
      groups.insert(0, rest.substring(rest.length - pattern.groupingSize));
      rest = rest.substring(0, rest.length - pattern.groupingSize);
    }
    groups.insert(0, rest);
    integerDigits = groups.join(format.groupingSeparator);
  }

  final zero = format.zeroDigit.codeUnitAt(0);
  String localize(String digits) => String.fromCharCodes(
    digits.codeUnits.map((c) => c >= 0x30 && c <= 0x39 ? zero + c - 0x30 : c),
  );

  var result = localize(integerDigits);
  if (fractionDigits.isNotEmpty) {
    result += format.decimalSeparator + localize(fractionDigits);
  }
  if (result.isEmpty) result = localize("0");

  return result;
}

/// Rounds non-negative [value] to [digits] fraction digits half to even using
/// exact binary value of the double. Returns integer part and fraction digits.
(BigInt, String) roundHalfEven(double value, int digits) {
  final (numerator, denominator) = _exactFraction(value);
  final scale = BigInt.from(10).pow(digits);
  final scaled = numerator * scale;

  var quotient = scaled ~/ denominator;
  final remainder2 = (scaled - quotient * denominator) * BigInt.two;

  if (remainder2 > denominator ||
      (remainder2 == denominator && quotient.isOdd)) {
    quotient += BigInt.one;
  }

  final integer = quotient ~/ scale;
  final fraction = (quotient - integer * scale).toString().padLeft(digits, "0");
  return (integer, digits == 0 ? "" : fraction);
}

/// Exact value of finite non-negative double as numerator / denominator.
(BigInt, BigInt) _exactFraction(double value) {
  final bytes = ByteData(8)..setFloat64(0, value);
  final bits = bytes.getUint64(0);
  final exponent = (bits >> 52) & 0x7FF;
  var mantissa = BigInt.from(bits & 0xFFFFFFFFFFFFF);

  int power;
  if (exponent == 0) {
    power = -1074;
  } else {
    mantissa += BigInt.one << 52;
    power = exponent - 1075;
  }

  return power >= 0
      ? (mantissa << power, BigInt.one)
      : (mantissa, BigInt.one << -power);
}
