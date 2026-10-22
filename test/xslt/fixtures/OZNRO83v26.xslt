<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
  <xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>
  <xsl:strip-space elements="*" />
  <xsl:template match="/">
    <xsl:text>OZNRO83v26</xsl:text>
    <xsl:text>&#xA;</xsl:text>
    <xsl:choose><xsl:when test="not(/dokument/hlavicka)"><xsl:call-template name="hlavicka" /></xsl:when><xsl:otherwise><xsl:if test="/dokument/hlavicka"><xsl:call-template name="hlavicka"></xsl:call-template></xsl:if></xsl:otherwise></xsl:choose><xsl:choose><xsl:when test="not(/dokument/odvod)"><xsl:call-template name="secOdvod" /></xsl:when><xsl:otherwise><xsl:if test="/dokument/odvod"><xsl:call-template name="secOdvod"></xsl:call-template></xsl:if></xsl:otherwise></xsl:choose><xsl:choose><xsl:when test="not(/dokument/vypracoval)"><xsl:call-template name="secVypracoval" /></xsl:when><xsl:otherwise><xsl:if test="/dokument/vypracoval"><xsl:call-template name="secVypracoval"></xsl:call-template></xsl:if></xsl:otherwise></xsl:choose></xsl:template>
  <xsl:template name="hlavicka">
    <xsl:if test="/dokument/hlavicka/dic/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Daňové identifikačné číslo: </xsl:text><xsl:value-of select="/dokument/hlavicka/dic"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/hlavicka/ico/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>IČO: </xsl:text><xsl:value-of select="/dokument/hlavicka/ico"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:choose><xsl:when test="not(/dokument/hlavicka/fyzickaOsoba)"><xsl:call-template name="fyzickaOsoba" /></xsl:when><xsl:otherwise><xsl:if test="/dokument/hlavicka/fyzickaOsoba"><xsl:call-template name="fyzickaOsoba"></xsl:call-template></xsl:if></xsl:otherwise></xsl:choose><xsl:choose><xsl:when test="not(/dokument/hlavicka/pravnickaOsoba)"><xsl:call-template name="pravnickaOsoba" /></xsl:when><xsl:otherwise><xsl:if test="/dokument/hlavicka/pravnickaOsoba"><xsl:call-template name="pravnickaOsoba"></xsl:call-template></xsl:if></xsl:otherwise></xsl:choose><xsl:choose><xsl:when test="not(/dokument/hlavicka/sidlo)"><xsl:call-template name="sidlo" /></xsl:when><xsl:otherwise><xsl:if test="/dokument/hlavicka/sidlo"><xsl:call-template name="sidlo"></xsl:call-template></xsl:if></xsl:otherwise></xsl:choose><xsl:choose><xsl:when test="not(/dokument/hlavicka/miestoPodnikaniaFO)"><xsl:call-template name="miestoPodnikaniaFO" /></xsl:when><xsl:otherwise><xsl:if test="/dokument/hlavicka/miestoPodnikaniaFO"><xsl:call-template name="miestoPodnikaniaFO"></xsl:call-template></xsl:if></xsl:otherwise></xsl:choose></xsl:template>
  <xsl:template name="secOdvod">
    <xsl:if test="/dokument/odvod/vysledok/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Výsledok hospodárenia: </xsl:text><xsl:value-of select="/dokument/odvod/vysledok"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:choose><xsl:when test="not(/dokument/odvod/zaObdobie)"><xsl:call-template name="zaObdobie" /></xsl:when><xsl:otherwise><xsl:if test="/dokument/odvod/zaObdobie"><xsl:call-template name="zaObdobie"></xsl:call-template></xsl:if></xsl:otherwise></xsl:choose>
    <xsl:if test="/dokument/odvod/vynosDlhopisu/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Suma výnosu štátneho dlhopisu: </xsl:text><xsl:value-of select="/dokument/odvod/vynosDlhopisu"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/odvod/koeficient/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Koeficient: </xsl:text><xsl:value-of select="/dokument/odvod/koeficient"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/odvod/odvod/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Výška osobitného odvodu z podnikania v regulovaných odvetviach: </xsl:text><xsl:value-of select="/dokument/odvod/odvod"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template name="secVypracoval">
    <xsl:if test="/dokument/vypracoval/vypracoval/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Vypracoval: </xsl:text><xsl:value-of select="/dokument/vypracoval/vypracoval"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/vypracoval/dna/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Dňa: </xsl:text><xsl:value-of select="/dokument/vypracoval/dna"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/vypracoval/telefon/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Telefónne číslo: </xsl:text><xsl:value-of select="/dokument/vypracoval/telefon"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/vypracoval/podpis/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Vyhlasujem, že všetky údaje uvedené v oznámení sú správne a úplné </xsl:text>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template name="fyzickaOsoba">
	<xsl:text>&#09;</xsl:text>
	<xsl:text>Identifikačné údaje regulovanej osoby</xsl:text>
	<xsl:text>&#xA;</xsl:text>
    <xsl:text>&#09;</xsl:text>
    <xsl:text>&#09;</xsl:text>
    <xsl:text>Fyzická osoba</xsl:text>
    <xsl:text>&#xA;</xsl:text>
    <xsl:if test="/dokument/hlavicka/fyzickaOsoba/priezvisko/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Priezvisko: </xsl:text><xsl:value-of select="/dokument/hlavicka/fyzickaOsoba/priezvisko"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/hlavicka/fyzickaOsoba/meno/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Meno: </xsl:text><xsl:value-of select="/dokument/hlavicka/fyzickaOsoba/meno"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/hlavicka/fyzickaOsoba/titulPred/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Titul pred menom: </xsl:text><xsl:value-of select="/dokument/hlavicka/fyzickaOsoba/titulPred"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/hlavicka/fyzickaOsoba/titulZa/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Titul za priezviskom: </xsl:text><xsl:value-of select="/dokument/hlavicka/fyzickaOsoba/titulZa"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/hlavicka/fyzickaOsoba/datumNarodenia/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Dátum narodenia: </xsl:text><xsl:value-of select="/dokument/hlavicka/fyzickaOsoba/datumNarodenia"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template name="pravnickaOsoba">
	<xsl:text>&#09;</xsl:text>
	<xsl:text>Identifikačné údaje regulovanej osoby</xsl:text>
	<xsl:text>&#xA;</xsl:text>
    <xsl:text>&#09;</xsl:text>
    <xsl:text>&#09;</xsl:text>
    <xsl:text>Právnická osoba</xsl:text>
    <xsl:text>&#xA;</xsl:text>
	  <xsl:if test="/dokument/hlavicka/pravnickaOsoba/obchodneMeno/riadok[1][normalize-space()]
           or /dokument/hlavicka/pravnickaOsoba/obchodneMeno/riadok[2][normalize-space()]">
		  <xsl:text>&#09;</xsl:text>
		  <xsl:text>&#09;</xsl:text>
		  <xsl:text>&#09;</xsl:text>
		  <xsl:text>Obchodné meno alebo názov: </xsl:text>

		  <xsl:for-each select="/dokument/hlavicka/pravnickaOsoba/obchodneMeno/riadok[normalize-space()]">
			  <xsl:if test="position() &gt; 1">, </xsl:if>
			  <xsl:value-of select="."/>
		  </xsl:for-each>

		  <xsl:text>&#xA;</xsl:text>
	  </xsl:if>

  </xsl:template>
  <xsl:template name="sidlo">
    <xsl:text>&#09;</xsl:text>
    <xsl:text>&#09;</xsl:text>
    <xsl:text>Adresa trvalého pobytu (fyzická osoba) / Adresa sídla (právnická osoba)</xsl:text>
    <xsl:text>&#xA;</xsl:text>
    <xsl:if test="/dokument/hlavicka/sidlo/ulica/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Ulica: </xsl:text><xsl:value-of select="/dokument/hlavicka/sidlo/ulica"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/hlavicka/sidlo/supisneOrientacneCislo/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Súpisné / orientačné číslo: </xsl:text><xsl:value-of select="/dokument/hlavicka/sidlo/supisneOrientacneCislo"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/hlavicka/sidlo/psc/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>PSČ: </xsl:text><xsl:value-of select="/dokument/hlavicka/sidlo/psc"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/hlavicka/sidlo/obec/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Obec: </xsl:text><xsl:value-of select="/dokument/hlavicka/sidlo/obec"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template name="miestoPodnikaniaFO">
    <xsl:text>&#09;</xsl:text>
    <xsl:text>&#09;</xsl:text>
    <xsl:text>Miesto podnikania fyzickej osoby, ak je odlišné od trvalého pobytu</xsl:text>
    <xsl:text>&#xA;</xsl:text>
    <xsl:if test="/dokument/hlavicka/miestoPodnikaniaFO/ulica/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Ulica: </xsl:text><xsl:value-of select="/dokument/hlavicka/miestoPodnikaniaFO/ulica"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/hlavicka/miestoPodnikaniaFO/supisneOrientacneCislo/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Súpisné / orientačné číslo: </xsl:text><xsl:value-of select="/dokument/hlavicka/miestoPodnikaniaFO/supisneOrientacneCislo"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/hlavicka/miestoPodnikaniaFO/psc/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>PSČ: </xsl:text><xsl:value-of select="/dokument/hlavicka/miestoPodnikaniaFO/psc"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/hlavicka/miestoPodnikaniaFO/obec/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Obec: </xsl:text><xsl:value-of select="/dokument/hlavicka/miestoPodnikaniaFO/obec"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template name="zaObdobie">
    <xsl:text>&#09;</xsl:text>
    <xsl:text>&#09;</xsl:text>
    <xsl:text>za účtovné obdobie</xsl:text>
    <xsl:text>&#xA;</xsl:text>
    <xsl:if test="/dokument/odvod/zaObdobie/datumOd/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Od: </xsl:text><xsl:value-of select="/dokument/odvod/zaObdobie/datumOd"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="/dokument/odvod/zaObdobie/datumDo/text()">
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:text>Do: </xsl:text><xsl:value-of select="/dokument/odvod/zaObdobie/datumDo"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="formatAnyUri">
    <xsl:param name="anyUri" />
    <xsl:variable name="anyUriString" select="string($anyUri)" />
    <xsl:variable name="anyUriSubString">
      <xsl:choose>
        <xsl:when test="$anyUriString != '' and contains($anyUriString, 'mailto:') and contains($anyUriString, '@')">
          <xsl:value-of select="substring($anyUriString, 8, string-length($anyUriString))" />
        </xsl:when>
        <xsl:when test="$anyUriString != '' and contains($anyUriString, 'http://')">
          <xsl:value-of select="substring($anyUriString, 8, string-length($anyUriString))" />
        </xsl:when>
        <xsl:when test="$anyUriString != '' and contains($anyUriString, 'https://')">
          <xsl:value-of select="substring($anyUriString, 9, string-length($anyUriString))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$anyUriString"></xsl:value-of>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$anyUriSubString"/>
  </xsl:template>
  <xsl:template name="booleanCheckboxToString">
    <xsl:param name="boolValue" />
    <xsl:variable name="boolValueString" select="string($boolValue)" />
    <xsl:choose>
      <xsl:when test="$boolValueString = 'true' ">
        <xsl:text>Áno</xsl:text>
      </xsl:when>
      <xsl:when test="$boolValueString = '1' ">
        <xsl:text>Áno</xsl:text>
      </xsl:when>
      <xsl:when test="$boolValueString = 'false' ">
        <xsl:text>Nie</xsl:text>
      </xsl:when>
      <xsl:when test="$boolValueString = '0' ">
        <xsl:text>Nie</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$boolValueString"></xsl:value-of>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="string-replace-all">
    <xsl:param name="text"/>
    <xsl:param name="replace"/>
    <xsl:param name="by"/>
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)"/>
        <xsl:value-of select="$by"/>
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text" select="substring-after($text,$replace)"/>
          <xsl:with-param name="replace" select="$replace"/>
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="formatToSkDate">
    <xsl:param name="date" />
    <xsl:variable name="dateString" select="string($date)" />
    <xsl:choose>
      <xsl:when test="$dateString != '' and string-length($dateString)=10 and string(number(substring($dateString, 1, 4))) != 'NaN' ">
        <xsl:value-of select="concat(substring($dateString, 9, 2), '.', substring($dateString, 6, 2), '.', substring($dateString, 1, 4))" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$dateString"></xsl:value-of>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="formatTimeTrimMinutes">
    <xsl:param name="time" />
    <xsl:variable name="timeString" select="string($time)" />
    <xsl:if test="$timeString != ''">
      <xsl:value-of select="substring($timeString, 1, 5)" />
    </xsl:if>
  </xsl:template>
  <xsl:template name="formatToSkDateTime">
    <xsl:param name="dateTime" />
    <xsl:variable name="dateSubstring" select="substring($dateTime, 1, 10)" />
    <xsl:variable name="timeSubstring" select="substring($dateTime, 12, 8)" />
    <xsl:variable name="dateString">
      <xsl:choose>
        <xsl:when test="$dateSubstring != '' and string-length($dateSubstring)=10 and string(number(substring($dateSubstring, 1, 4))) != 'NaN' ">
          <xsl:value-of select="concat(substring($dateSubstring, 9, 2), '.', substring($dateSubstring, 6, 2), '.', substring($dateSubstring, 1, 4))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$dateSubstring"></xsl:value-of>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="timeString">
      <xsl:if test="$timeSubstring != ''">
        <xsl:value-of select="substring($timeSubstring, 1, 5)" />
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="concat($dateString,' ',$timeString)"/>
  </xsl:template>
</xsl:stylesheet>
