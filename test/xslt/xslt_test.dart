import 'dart:io' show File;

import 'package:autogram/xslt/xslt.dart';
import 'package:flutter_test/flutter_test.dart';

const _fixtures = "test/xslt/fixtures";

/// Transforms [xml] by [stylesheet] (body of `xsl:stylesheet`).
String _transform(String stylesheet, String xml, {String attributes = ""}) {
  final processor = XsltProcessor.parse('''
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" $attributes>
$stylesheet
</xsl:stylesheet>''');

  return processor.transformDocument(parseXml(xml)).content;
}

/// Evaluates XPath [expression] as string on [xml].
String _evaluate(String expression, [String xml = "<root/>"]) {
  return _transform('''
<xsl:output method="text"/>
<xsl:template match="/"><xsl:value-of select="$expression"/></xsl:template>''', xml);
}

void main() {
  group('XSLT e-form fixtures', () {
    // expected outputs were created by Saxon as AVM service visualization
    for (final (xslt, xml, expected) in [
      ("general_agenda", "general_agenda", "general_agenda"),
      ("OZNRO83v26", "OZNRO83v26_0", "OZNRO83v26_0"),
      ("OZNRO83v26", "OZNRO83v26_1", "OZNRO83v26_1"),
      ("OZNRO32v26", "OZNRO32v26_0", "OZNRO32v26_0"),
      ("OZNRO32v26", "OZNRO32v26_1", "OZNRO32v26_1"),
    ]) {
      test('$xml transformed by $xslt.xslt equals Saxon output', () {
        final processor = XsltProcessor.parse(
          File("$_fixtures/$xslt.xslt").readAsStringSync(),
        );
        final result = processor.transformDocument(
          parseXml(File("$_fixtures/$xml.xml").readAsStringSync()),
        );

        expect(result.method, OutputMethod.text);
        expect(result.content, File("$_fixtures/$expected.txt").readAsStringSync());
      });
    }
  });

  group('XPath', () {
    test('converts numbers to strings without exponent', () {
      expect(_evaluate("1 div 3"), "0.3333333333333333");
      expect(_evaluate("1000000 * 1000000 * 1000000 * 1000"), "1000000000000000000000");
      expect(_evaluate("0.0000001"), "0.0000001");
      expect(_evaluate("-0"), "0");
      expect(_evaluate("2.50"), "2.5");
      expect(_evaluate("1 div 0"), "Infinity");
      expect(_evaluate("-1 div 0"), "-Infinity");
      expect(_evaluate("0 div 0"), "NaN");
      expect(_evaluate("number('1e3')"), "NaN");
      expect(_evaluate("number(' -12.5 ')"), "-12.5");
    });

    test('evaluates arithmetic', () {
      expect(_evaluate("5 mod 2"), "1");
      expect(_evaluate("-5 mod 2"), "-1");
      expect(_evaluate("7 div 2"), "3.5");
      expect(_evaluate("round(2.5)"), "3");
      expect(_evaluate("round(-2.5)"), "-2");
      expect(_evaluate("floor(-1.5)"), "-2");
      expect(_evaluate("ceiling(1.2)"), "2");
      expect(_evaluate("sum(//n)", "<r><n>1</n><n>2.5</n></r>"), "3.5");
    });

    test('evaluates string functions', () {
      expect(_evaluate("substring('12345', 1.5, 2.6)"), "234");
      expect(_evaluate("substring('12345', 0, 3)"), "12");
      expect(_evaluate("substring('12345', 0 div 0, 3)"), "");
      expect(_evaluate("substring('12345', -42, 1 div 0)"), "12345");
      expect(_evaluate("substring-before('1999/04/01', '/')"), "1999");
      expect(_evaluate("substring-after('1999/04/01', '/')"), "04/01");
      expect(_evaluate("translate('--aaa--', 'abc-', 'ABC')"), "AAA");
      expect(_evaluate("normalize-space('  a \n  b ')"), "a b");
      expect(_evaluate("string-length('Žilina')"), "6");
      expect(_evaluate("concat('a', 1, true())"), "a1true");
      expect(_evaluate("starts-with('abc', 'ab')"), "true");
      expect(_evaluate("contains('abc', 'd')"), "false");
    });

    test('compares node-sets according to XPath 1.0', () {
      const xml = "<r><a>1</a><a>2</a><b>2</b><c/></r>";

      expect(_evaluate("//a = 2", xml), "true");
      expect(_evaluate("//a != 2", xml), "true");
      expect(_evaluate("//a = //b", xml), "true");
      expect(_evaluate("//a > 1", xml), "true");
      expect(_evaluate("//a > 2", xml), "false");
      expect(_evaluate("//a = '1'", xml), "true");
      expect(_evaluate("//x = ''", xml), "false");
      expect(_evaluate("//x != ''", xml), "false");
      expect(_evaluate("//c = ''", xml), "true");
      expect(_evaluate("//x = false()", xml), "true");
      expect(_evaluate("'1.0' = 1", xml), "true");
      expect(_evaluate("true() = 'false'", xml), "true");
    });

    test('evaluates axes and predicates', () {
      const xml = "<r><a i='1'/><a i='2'><b/></a><a i='3'/></r>";

      expect(_evaluate("count(//a)", xml), "3");
      expect(_evaluate("//a[last()]/@i", xml), "3");
      expect(_evaluate("//a[2]/@i", xml), "2");
      expect(_evaluate("//b/ancestor::*[1]/@i", xml), "2");
      expect(_evaluate("//a[@i=3]/preceding-sibling::a[1]/@i", xml), "2");
      expect(_evaluate("count(//b/preceding::*)", xml), "1");
      expect(_evaluate("count(//b/following::*)", xml), "1");
      expect(_evaluate("name(//a[1]/following-sibling::*[2])", xml), "a");
      expect(_evaluate("(//a | //b)[2]/@i", xml), "2");
      expect(_evaluate("count(//@*)", xml), "3");
      expect(_evaluate("local-name(//b/..)", xml), "a");
    });

    test('resolves namespaces of name tests', () {
      const xml =
          '<f:form xmlns:f="urn:form"><item xmlns="urn:form">x</item></f:form>';

      expect(
        _transform(r'''
<xsl:output method="text"/>
<xsl:template match="/"><xsl:value-of select="concat(local-name(/*), ':', /e:form/e:item)"/></xsl:template>''',
            xml, attributes: 'xmlns:e="urn:form"'),
        "form:x",
      );
      expect(_evaluate("count(/form)", xml), "0");
    });
  });

  group('XSLT', () {
    test('selects template rule by priority and order', () {
      const xml = "<r><a/><b/><c x='1'/></r>";

      expect(
        _transform(r'''
<xsl:output method="text"/>
<xsl:template match="r"><xsl:apply-templates/></xsl:template>
<xsl:template match="*">[any]</xsl:template>
<xsl:template match="a">[a]</xsl:template>
<xsl:template match="r/b">[r/b]</xsl:template>
<xsl:template match="b">[b]</xsl:template>
<xsl:template match="c[@x]" priority="-1">[c with x]</xsl:template>
<xsl:template match="c">[c]</xsl:template>''', xml),
        "[a][r/b][c]",
      );
    });

    test('uses built-in template rules and modes', () {
      expect(
        _transform(r'''
<xsl:output method="text"/>
<xsl:template match="/"><xsl:apply-templates/>|<xsl:apply-templates mode="m"/></xsl:template>
<xsl:template match="b" mode="m">B</xsl:template>''', "<r>t<a>x</a><b>y</b></r>"),
        "txy|txB",
      );
    });

    test('passes parameters and uses local variables', () {
      expect(
        _transform(r'''
<xsl:output method="text"/>
<xsl:variable name="global" select="'G'"/>
<xsl:template match="/">
  <xsl:variable name="local">L</xsl:variable>
  <xsl:call-template name="t">
    <xsl:with-param name="p" select="concat($global, $local)"/>
  </xsl:call-template>
</xsl:template>
<xsl:template name="t">
  <xsl:param name="p"/>
  <xsl:param name="default" select="'D'"/>
  <xsl:value-of select="concat($p, $default)"/>
</xsl:template>''', "<r/>"),
        "GLD",
      );
    });

    test('recursive template replaces all occurrences', () {
      expect(
        _transform(r'''
<xsl:output method="text"/>
<xsl:template match="/">
  <xsl:call-template name="replace">
    <xsl:with-param name="text" select="string(r)"/>
  </xsl:call-template>
</xsl:template>
<xsl:template name="replace">
  <xsl:param name="text"/>
  <xsl:choose>
    <xsl:when test="contains($text, '&#10;')">
      <xsl:value-of select="substring-before($text, '&#10;')"/>
      <xsl:text>&#13;&#10;&#09;</xsl:text>
      <xsl:call-template name="replace">
        <xsl:with-param name="text" select="substring-after($text, '&#10;')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
  </xsl:choose>
</xsl:template>''', "<r>a\nb\r\nc</r>"),
        "a\r\n\tb\r\n\tc",
      );
    });

    test('sorts nodes', () {
      const xml = "<r><i n='10'>b</i><i n='9'>a</i><i n='11'>c</i></r>";

      expect(
        _transform(r'''
<xsl:output method="text"/>
<xsl:template match="/">
  <xsl:for-each select="r/i"><xsl:sort select="@n" data-type="number" order="descending"/><xsl:value-of select="."/></xsl:for-each>
  <xsl:text>|</xsl:text>
  <xsl:apply-templates select="r/i"><xsl:sort select="@n"/></xsl:apply-templates>
</xsl:template>
<xsl:template match="i"><xsl:value-of select="concat(., position())"/></xsl:template>''', xml),
        "cba|b1c2a3",
      );
    });

    test('uses result tree fragments and keys', () {
      const xml = "<r><p id='1' name='one'/><p id='2' name='two'/><ref to='2'/></r>";

      expect(
        _transform(r'''
<xsl:output method="text"/>
<xsl:key name="person" match="p" use="@id"/>
<xsl:template match="/">
  <xsl:variable name="fragment"><a>x</a><a>y</a></xsl:variable>
  <xsl:value-of select="concat($fragment, '|', count($fragment/a), '|', key('person', r/ref/@to)/@name)"/>
</xsl:template>''', xml),
        "xy|2|two",
      );
    });

    test('formats numbers', () {
      expect(_evaluate("format-number(1234567.891, '#,##0.00')"), "1,234,567.89");
      expect(_evaluate("format-number(0.5, '0%')"), "50%");
      expect(_evaluate("format-number(2.5, '0')"), "2");
      expect(_evaluate("format-number(-3, '#;(#)')"), "(3)");
      expect(
        _transform(r'''
<xsl:output method="text"/>
<xsl:decimal-format name="sk" decimal-separator="," grouping-separator=" "/>
<xsl:template match="/"><xsl:value-of select="format-number(1234.5, '# ##0,00', 'sk')"/></xsl:template>''', "<r/>"),
        "1 234,50",
      );
    });

    test('numbers nodes', () {
      expect(
        _transform(r'''
<xsl:output method="text"/>
<xsl:template match="i"><xsl:number format="a) "/><xsl:number value="position()" format="I"/>;</xsl:template>''',
            "<r><i/><i/><i/></r>"),
        "a) I;b) II;c) III;",
      );
    });

    test('strips whitespace of source and stylesheet', () {
      expect(
        _transform(r'''
<xsl:output method="text"/>
<xsl:strip-space elements="*"/>
<xsl:template match="/">
  <xsl:value-of select="count(r/node())"/>
  <xsl:text> </xsl:text>
</xsl:template>''', "<r>\n  <a/>\n  <b/>\n</r>"),
        "2 ",
      );
    });

    test('creates elements and attributes in HTML output', () {
      expect(
        _transform(r'''
<xsl:output method="html" doctype-public="-//W3C//DTD HTML 4.01//EN"/>
<xsl:template match="/">
  <html><head><title>T</title></head><body>
    <p class="{r/@c}"><xsl:value-of select="r"/></p>
    <br/>
    <xsl:element name="input">
      <xsl:attribute name="checked">checked</xsl:attribute>
      <xsl:attribute name="value">a&amp;b "c"</xsl:attribute>
    </xsl:element>
    <script>if (a &lt; b) {}</script>
  </body></html>
</xsl:template>''', "<r c='x'>&lt;b&gt;</r>"),
        '<!DOCTYPE html\n  PUBLIC "-//W3C//DTD HTML 4.01//EN">\n'
        '<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><title>T</title></head><body>'
        '<p class="x">&lt;b&gt;</p><br><input checked value="a&amp;b &quot;c&quot;">'
        '<script>if (a < b) {}</script></body></html>',
      );
    });

    test('copies nodes in XML output', () {
      expect(
        _transform(r'''
<xsl:output method="xml" omit-xml-declaration="yes"/>
<xsl:template match="/"><out xmlns:x="urn:x"><xsl:copy-of select="r/*"/><xsl:apply-templates select="r/b"/></out></xsl:template>
<xsl:template match="b"><xsl:copy><xsl:attribute name="n">1</xsl:attribute></xsl:copy></xsl:template>''',
            "<r><a k='v'>t</a><b/></r>"),
        '<out xmlns:x="urn:x"><a k="v">t</a><b/><b n="1"/></out>',
      );
    });

    test('disables output escaping', () {
      expect(
        _transform(r'''
<xsl:output method="html"/>
<xsl:template match="/"><p><xsl:text disable-output-escaping="yes">&lt;b&gt;bold&lt;/b&gt;</xsl:text></p></xsl:template>''',
            "<r/>"),
        "<p><b>bold</b></p>",
      );
    });

    test('refuses unsupported features', () {
      expect(
        () => XsltProcessor.parse(r'''
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="https://example.com/other.xslt"/>
</xsl:stylesheet>'''),
        throwsA(isA<XsltException>()),
      );
      expect(
        () => _evaluate("count(document('https://example.com/data.xml'))"),
        throwsA(isA<XsltException>()),
      );
      expect(() => _evaluate("unknown-function()"), throwsA(isA<XsltException>()));
    });

    test('limits recursion', () {
      expect(
        () => _transform(r'''
<xsl:template match="/"><xsl:call-template name="loop"/></xsl:template>
<xsl:template name="loop"><xsl:call-template name="loop"/></xsl:template>''', "<r/>"),
        throwsA(isA<XsltException>()),
      );
    });
  });
}
