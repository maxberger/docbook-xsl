<?xml version='1.0'?>
<!-- vim:set sts=2 shiftwidth=2 syntax=sgml: -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='1.0'>

<xsl:template match="varlistentry">
  <xsl:text>
.TP
</xsl:text>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="varlistentry/term">
  <xsl:apply-templates/>
  <xsl:text>, </xsl:text>
</xsl:template>

<xsl:template match="varlistentry/term[position()=last()]" priority="2">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="itemizedlist/listitem">
  <xsl:text>
\(bu </xsl:text>
  <xsl:apply-templates/>
  <xsl:text>
.Sp
</xsl:text>
</xsl:template>

<xsl:template match="varlistentry/listitem/para">
  <xsl:variable name="foo">
    <xsl:apply-templates/>
  </xsl:variable>
  <xsl:text>
</xsl:text>
  <xsl:value-of select="normalize-space($foo)"/>
  <xsl:text>
</xsl:text>
</xsl:template>

</xsl:stylesheet>
