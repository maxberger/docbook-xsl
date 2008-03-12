<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:fo="http://www.w3.org/1999/XSL/Format"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:db="http://docbook.org/ns/docbook"
                xmlns:t="http://docbook.org/xslt/ns/template"
		exclude-result-prefixes="f m fn db t"
                version="2.0">

<xsl:template name="dingbat">
  <xsl:param name="dingbat">bullet</xsl:param>
  <xsl:variable name="symbol">
    <xsl:choose>
      <xsl:when test="$dingbat='bullet'">o</xsl:when>
      <xsl:when test="$dingbat='copyright'">&#x00A9;</xsl:when>
      <xsl:when test="$dingbat='trademark'">&#x2122;</xsl:when>
      <xsl:when test="$dingbat='trade'">&#x2122;</xsl:when>
      <xsl:when test="$dingbat='registered'">&#x00AE;</xsl:when>
      <xsl:when test="$dingbat='service'">(SM)</xsl:when>
      <xsl:when test="$dingbat='ldquo'">"</xsl:when>
      <xsl:when test="$dingbat='rdquo'">"</xsl:when>
      <xsl:when test="$dingbat='lsquo'">'</xsl:when>
      <xsl:when test="$dingbat='rsquo'">'</xsl:when>
      <xsl:when test="$dingbat='em-dash'">&#x2014;</xsl:when>
      <xsl:when test="$dingbat='en-dash'">-</xsl:when>
      <xsl:otherwise>o</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$dingbat.font.family = ''">
      <xsl:copy-of select="$symbol"/>
    </xsl:when>
    <xsl:otherwise>
      <fo:inline font-family="{$dingbat.font.family}">
        <xsl:copy-of select="$symbol"/>
      </fo:inline>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="t:page-sequence-attributes">
  <!--
    <xsl:attribute name="language">
      <xsl:call-template name="l10n.language"/>
    </xsl:attribute>

    <xsl:attribute name="format">
      <xsl:call-template name="page.number.format">
        <xsl:with-param name="master-reference" select="$master-reference"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:attribute name="initial-page-number">
      <xsl:call-template name="initial.page.number">
        <xsl:with-param name="master-reference" select="$master-reference"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:attribute name="force-page-count">
      <xsl:call-template name="force.page.count">
        <xsl:with-param name="master-reference" select="$master-reference"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:attribute name="hyphenation-character">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-character'"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="hyphenation-push-character-count">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-push-character-count'"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="hyphenation-remain-character-count">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-remain-character-count'"/>
      </xsl:call-template>
    </xsl:attribute>
  -->
</xsl:template>

</xsl:stylesheet>
