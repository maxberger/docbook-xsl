<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                exclude-result-prefixes="doc"
                version="1.0">

<xsl:output method="xml" encoding="US-ASCII" indent="yes"/>

<xsl:strip-space elements="localization locale context"/>

<xsl:template match="doc:*"/>

<xsl:template match="locale">
  <localization language="{@language}">
    <xsl:text>&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:comment> This file is generated automatically. </xsl:comment>
    <xsl:text>&#10;</xsl:text>
    <xsl:comment> Do not edit this file by hand! </xsl:comment>
    <xsl:text>&#10;</xsl:text>
    <xsl:comment> See http://docbook.sourceforge.net/ </xsl:comment>
    <xsl:text>&#10;</xsl:text>

    <xsl:apply-templates/>

  </localization>
  <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="gentext|dingbat">
  <xsl:element name="{name(.)}">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="context">
  <xsl:text>&#10;</xsl:text>
  <xsl:element name="{name(.)}">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="template">
  <template>
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="text">
      <xsl:apply-templates select="node()" mode="template-text"/>
    </xsl:attribute>
  </template>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="template-text">
  <xsl:variable name="key" select="local-name(.)"/>
  <xsl:variable name="gentext" select="ancestor::locale//gentext[@key=$key]"/>

  <xsl:if test="count($gentext) = 0">
    <xsl:message terminate="yes">
      <xsl:text>There is no gentext key '</xsl:text>
      <xsl:value-of select="$key"/>
      <xsl:text>' in the '</xsl:text>
      <xsl:value-of select="ancestor::locale/@language"/>
      <xsl:text>' locale.</xsl:text>
    </xsl:message>
  </xsl:if>

  <xsl:if test="count($gentext) &gt; 1">
    <xsl:message>
      <xsl:text>There is more than one gentext key '</xsl:text>
      <xsl:value-of select="$key"/>
      <xsl:text>' in the '</xsl:text>
      <xsl:value-of select="ancestor::locale/@language"/>
      <xsl:text>' locale.</xsl:text>
    </xsl:message>
  </xsl:if>

  <xsl:value-of select="$gentext[1]/@text"/>
</xsl:template>

<xsl:template match="text()" mode="template-text">
  <xsl:value-of select="."/>
</xsl:template>

<!-- ============================================================ -->

</xsl:stylesheet>
