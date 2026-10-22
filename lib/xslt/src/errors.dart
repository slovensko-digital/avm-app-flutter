/// Error of XPath expression parsing or evaluation.
class XPathException implements Exception {
  final String message;

  const XPathException(this.message);

  @override
  String toString() => "XPathException: $message";
}

/// Error of XSLT stylesheet compilation or transformation, also used for
/// XSLT features not supported by this implementation.
class XsltException implements Exception {
  final String message;

  const XsltException(this.message);

  @override
  String toString() => "XsltException: $message";
}
