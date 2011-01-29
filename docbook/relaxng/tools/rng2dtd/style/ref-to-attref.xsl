<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="http://purl.oclc.org/dsdl/schematron"
                xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
                xmlns:dtx="http://nwalsh.com/ns/dtd-xml"
                xmlns:f="http://nwalsh.com/functions/dtd-xml"
                xmlns="http://nwalsh.com/ns/dtd-xml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="s a dtx xs f"
                version="2.0">

<xsl:include href="common.xsl"/>

<!-- Change ref's that point exclusively to attributes into attref's -->

<xsl:key name="name" match="dtx:pe|dtx:element" use="@name"/>

<xsl:template match="dtx:ref">
  <xsl:variable name="attref" select="f:only-attributes(.)"/>

  <xsl:choose>
    <xsl:when test="$attref">
      <attref>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
      </attref>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
