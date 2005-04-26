<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:fn="http://www.w3.org/2005/04/xpath-functions"
		xmlns:db="http://docbook.org/ns/docbook"
		exclude-result-prefixes="h f m fn db t"
                version="2.0">

  <xsl:include href="param.xsl"/>
  <xsl:include href="../common/l10n.xsl"/>
  <xsl:include href="../common/spspace.xsl"/>
  <xsl:include href="../common/gentext.xsl"/>
  <xsl:include href="../common/normalize.xsl"/>
  <xsl:include href="../common/root.xsl"/>
  <xsl:include href="../common/functions.xsl"/>
  <xsl:include href="../common/common.xsl"/>
  <xsl:include href="../common/titlepages.xsl"/>
  <xsl:include href="../common/labels.xsl"/>
  <xsl:include href="../common/titles.xsl"/>
  <xsl:include href="../common/inlines.xsl"/>
  <xsl:include href="titlepages.xsl"/>
  <xsl:include href="titlepage.xsl"/>
  <xsl:include href="autotoc.xsl"/>
  <xsl:include href="division.xsl"/>
  <xsl:include href="component.xsl"/>
  <xsl:include href="refentry.xsl"/>
  <xsl:include href="synopsis.xsl"/>
  <xsl:include href="section.xsl"/>
  <xsl:include href="biblio.xsl"/>
  <xsl:include href="pi.xsl"/>
  <xsl:include href="info.xsl"/>
  <xsl:include href="glossary.xsl"/>
  <xsl:include href="table.xsl"/>
  <xsl:include href="lists.xsl"/>
  <xsl:include href="formal.xsl"/>
  <xsl:include href="blocks.xsl"/>
  <xsl:include href="graphics.xsl"/>
  <xsl:include href="footnotes.xsl"/>
  <xsl:include href="admonitions.xsl"/>
  <xsl:include href="verbatim.xsl"/>
  <xsl:include href="qandaset.xsl"/>
  <xsl:include href="inlines.xsl"/>
  <xsl:include href="xref.xsl"/>
  <xsl:include href="math.xsl"/>
  <xsl:include href="html.xsl"/>
  <xsl:include href="index.xsl"/>
  <xsl:include href="autoidx.xsl"/>
  <xsl:include href="chunker.xsl"/>

  <xsl:output method="xml" encoding="utf-8" indent="yes"/>
  <xsl:output name="final" method="xhtml" encoding="utf-8" indent="yes"/>

  <xsl:param name="stylesheet.result.type" select="'xhtml'"/>

  <xsl:template match="*" mode="m:root">
    <xsl:result-document href="normalized.xml">
      <xsl:copy-of select="."/>
    </xsl:result-document>
    <!--
    <xsl:result-document href="normalized-glossary.xml">
      <xsl:copy-of select="$external.glossary"/>
    </xsl:result-document>
    -->

    <xsl:result-document format="final">
      <html>
	<head>
	  <title>
	    <xsl:choose>
	      <xsl:when test="db:info/db:title">
		<xsl:value-of select="db:info/db:title"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text>???</xsl:text>
		<xsl:message>
		  <xsl:text>Warning: no title for root element: </xsl:text>
		  <xsl:value-of select="local-name(.)"/>
		</xsl:message>
	      </xsl:otherwise>
	    </xsl:choose>
	  </title>
	  <xsl:call-template name="css-style"/>
	</head>
	<body>
	  <xsl:apply-templates select="."/>
	</body>
      </html>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="*">
    <div class="unknowntag">
      <xsl:call-template name="id"/>
      <font color="red">
	<xsl:text>&lt;</xsl:text>
	<xsl:value-of select="name(.)"/>
	<xsl:for-each select="@*">
	  <xsl:text> </xsl:text>
	  <xsl:value-of select="name(.)"/>
	  <xsl:text>="</xsl:text>
	  <xsl:value-of select="."/>
	  <xsl:text>"</xsl:text>
	</xsl:for-each>
	<xsl:text>&gt;</xsl:text>
      </font>
      <xsl:apply-templates/>
      <font color="red">
	<xsl:text>&lt;/</xsl:text>
	<xsl:value-of select="name(.)"/>
	<xsl:text>&gt;</xsl:text>
      </font>
    </div>
  </xsl:template>

</xsl:stylesheet>
