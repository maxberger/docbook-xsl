<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:html='http://www.w3.org/1999/xhtml'
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                exclude-result-prefixes="doc html"
                version='1.0'>

<!-- ********************************************************************
     $Id$
     ********************************************************************

     This file is part of the WebSite distribution.
     See ../README or http://nwalsh.com/website/ for copyright
     and other information.

     ******************************************************************** -->

<!-- ==================================================================== -->

<xsl:include href="website-common.xsl"/>
<xsl:include href="toc.xsl"/>

<xsl:output method="html"
            indent="no"
            doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
            doctype-system="http://www.w3.org/TR/html4/loose.dtd"
/>

<xsl:param name="autolayout-file" select="'autolayout.xml'"/>
<xsl:param name="autolayout" select="document($autolayout-file,/*[1])"/>

<xsl:attribute-set name="body.attributes"/>

<!-- ==================================================================== -->

<xsl:template match="webpage">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="filename">
    <xsl:apply-templates select="." mode="filename"/>
  </xsl:variable>

  <xsl:variable name="tocentry" select="$autolayout/autolayout//*[$id=@id]"/>
  <xsl:variable name="toc" select="$tocentry/ancestor-or-self::toc"/>

  <html>
    <xsl:apply-templates select="head" mode="head.mode"/>
    <xsl:apply-templates select="config" mode="head.mode"/>
    <body xsl:use-attribute-sets="body.attributes">

      <div id="{$id}" class="{name(.)}">
        <a name="{$id}"/>

        <xsl:if test="$toc">
          <div class="navhead">
            <xsl:apply-templates select="$toc">
              <xsl:with-param name="pageid" select="@id"/>
            </xsl:apply-templates>
            <xsl:if test="$header.hr != 0"><hr/></xsl:if>
          </div>
        </xsl:if>

        <xsl:apply-templates select="./head/title" mode="title.mode"/>

        <xsl:apply-templates select="child::*[name(.)!='webpage']"/>

        <xsl:call-template name="process.footnotes"/>

        <xsl:call-template name="webpage.footer"/>
      </div>
    </body>
  </html>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="webtoc">
  <xsl:variable name="webpage" select="ancestor::webpage"/>
  <xsl:variable name="relpath">
    <xsl:call-template name="root-rel-path">
      <xsl:with-param name="webpage" select="$webpage"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="pageid" select="$webpage/@id"/>

  <xsl:variable name="pages"
                select="$autolayout//*[$pageid=@id]/tocentry"/>

  <xsl:if test="count($pages) > 0">
    <ul class="toc">
      <xsl:for-each select="$pages">
        <li>
          <a href="{$relpath}{@dir}{$filename-prefix}{@filename}">
            <xsl:apply-templates select="title"/>
          </a>
          <xsl:if test="summary">
            <xsl:text>--</xsl:text>
            <xsl:apply-templates select="summary"/>
          </xsl:if>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:if>
</xsl:template>

<xsl:template match="toc/summary|tocentry/summary|notoc/summary">
  <xsl:apply-templates/>
</xsl:template>

<!-- ==================================================================== -->

</xsl:stylesheet>
