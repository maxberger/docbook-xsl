<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                exclude-result-prefixes="doc"
                version="1.0">

<xsl:output method="xml" encoding="US-ASCII" indent="no"/>

<xsl:strip-space elements="localization locale context"/>

<xsl:template match="doc:*"/>

<xsl:template match="locale">
  <xsl:text>&#10;</xsl:text>
  <xsl:comment> This file is generated automatically. </xsl:comment>
  <xsl:text>&#10;</xsl:text>
  <xsl:comment> Do not edit this file by hand! </xsl:comment>
  <xsl:text>&#10;</xsl:text>
  <xsl:comment> See http://docbook.sourceforge.net/ </xsl:comment>
  <xsl:text>&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:apply-templates select="gentext"/>
</xsl:template>

<xsl:template match="gentext">
  <xsl:if test="not(contains(@key, ' '))">
    <xsl:text disable-output-escaping="yes">&lt;!ENTITY </xsl:text>

    <xsl:value-of select="@key"/>

    <xsl:if test="string-length(@key) &lt; 15"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt; 14"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt; 13"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt; 12"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt; 11"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt; 10"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt;  9"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt;  8"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt;  7"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt;  6"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt;  5"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt;  4"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt;  3"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt;  2"><xsl:text> </xsl:text></xsl:if>
    <xsl:if test="string-length(@key) &lt;  1"><xsl:text> </xsl:text></xsl:if>

    <xsl:text> "</xsl:text>
    <xsl:value-of select="@text"/>
    <xsl:text>"</xsl:text>
    <xsl:text disable-output-escaping="yes">&gt;&#10;</xsl:text>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
